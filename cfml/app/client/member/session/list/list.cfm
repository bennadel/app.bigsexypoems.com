<cfscript>

	// Define properties for dependency-injection.
	listGateway = request.ioc.get( "client.member.session.list.ListGateway" );
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	sessionService = request.ioc.get( "core.lib.service.session.SessionService" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="form.action" type="string" default="";
	param name="form.sessionID" type="numeric" default=0;

	partial = getPartial( request.authContext );
	title = "Active Sessions";
	sessions = partial.sessions;
	errorResponse = "";

	request.response.title = title;
	// Note: no terminal breadcrumb for default views.

	if ( request.isPost ) {

		try {

			switch ( form.action ) {
				case "endSession":

					sessionService.endSession(
						authContext = request.authContext,
						sessionID = val( form.sessionID )
					);

					nextEvent = ( request.authContext.session.id == form.sessionID )
						// Logged-out of the current session.
						? "auth.logout.success"
						// Logged-out of a adjacent session.
						: "member.session"
					;

					router.goto({
						event: nextEvent,
						flash: "your.session.deleted"
					});

				break;
				case "endAllSessions":

					sessionService.endAllSessions(
						authContext = request.authContext,
						userID = request.authContext.user.id
					);

					router.goto({
						event: "auth.logout.success",
						flash: "your.session.allDeleted"
					});

				break;
			}

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	}

	include "./list.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial( required struct authContext ) {

		var sessions = listGateway.getSessions( authContext.user.id );

		for ( var entry in sessions ) {

			entry.isCurrent = ( entry.id == authContext.session.id );
			entry.ipLocation = getIpLocation( entry.ipCity, entry.ipRegion, entry.ipCountry );

		}

		return {
			sessions
		};

	}

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I format the location using the given parts.
	*/
	private string function getIpLocation(
		required string ipCity,
		required string ipRegion,
		required string ipCountry
		) {

		var result = ipCity;

		if ( ipRegion.len() ) {

			result = result.listAppend( ipRegion, ", " );

		}

		if ( ipCountry.len() ) {

			result = result.listAppend( "(#ipCountry#)", " " );

		}

		return result;

	}

</cfscript>
