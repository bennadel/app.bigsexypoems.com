<cfscript>

	// Define properties for dependency-injection.
	poemRevisionService = request.ioc.get( "core.lib.service.poem.PoemRevisionService" );
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.poemID" type="numeric";

	request.response.template = "blank";

	if ( request.isPost ) {

		try {

			poemRevisionService.createRevision(
				authContext = request.authContext,
				poemID = val( url.poemID )
			);

		} catch ( any error ) {

			requestHelper.processError( error );

		}

	}

	include "./createRevision.view.cfm";

</cfscript>
