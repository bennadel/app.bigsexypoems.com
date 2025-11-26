<cfscript>

	// Define properties for dependency-injection.
	poemAccess = request.ioc.get( "core.lib.service.poem.PoemAccess" );
	poemService = request.ioc.get( "core.lib.service.poem.PoemService" );
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.poemID" type="numeric";
	param name="form.isConfirmed" type="boolean" default=false;

	partial = getPartial(
		authContext = request.authContext,
		poemID = val( url.poemID )
	);
	poem = partial.poem;

	title = "Delete Poem";
	errorResponse = "";

	request.response.title = title;
	request.response.breadcrumbs.append( request.breadcrumbForPoem( poem ) );
	request.response.breadcrumbs.append( "Delete Confirmation" );

	if ( request.isPost ) {

		try {

			if ( ! form.isConfirmed ) {

				throw( type = "App.ConfirmationRequired" );

			}

			poemService.delete(
				authContext = request.authContext,
				id = poem.id
			);

			router.goto([
				event: "member.poem",
				flash: "your.poem.deleted"
			]);

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	}

	include "./delete.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial(
		required struct authContext,
		required numeric poemID
		) {

		var context = poemAccess.getContext( authContext, poemID, "canDelete" );
		var poem = context.poem;

		return {
			poem
		};

	}

</cfscript>
