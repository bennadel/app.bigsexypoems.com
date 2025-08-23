<cfscript>

	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	sessionService = request.ioc.get( "core.lib.service.session.SessionService" );
	ui = request.ioc.get( "core.lib.web.UI" );
	viewPartial = request.ioc.get( "client.account.session.list.ListPartial" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="form.action" type="string" default="";
	param name="form.sessionID" type="numeric" default=0;

	partial = viewPartial.getPartial( request.authContext );
	title = "Active Sessions";
	sessions = partial.sessions;
	errorResponse = "";

	request.response.title = title;

	if ( request.isPost ) {

		try {

			switch ( form.action ) {
				case "endSession":

					sessionService.endSession(
						userID = request.authContext.user.id,
						sessionID = val( form.sessionID )
					);

					nextEvent = ( request.authContext.session.id == form.sessionID )
						// Logged-out of the current session.
						? "auth.logout.success"
						// Logged-out of a adjacent session.
						: "account.session"
					;

					router.goto({
						event: nextEvent,
						flash: "your.session.deleted"
					});

				break;
				case "endAllSessions":

					sessionService.endAllSessions( request.authContext.user.id );

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

</cfscript>
