<cfscript>

	poemService = request.ioc.get( "core.lib.service.poem.PoemService" );
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="form.name" type="string" default="";
	param name="form.content" type="string" default="";

	title = "Create New Poem";
	errorResponse = "";

	request.response.title = title;

	if ( request.isPost ) {

		try {

			poemID = poemService.createPoem(
				authContext = request.authContext,
				userID = request.authContext.user.id,
				poemName = form.name,
				poemContent = form.content
			);

			router.goto([
				event: "member.poems.view",
				poemID: poemID,
				flash: "your.poem.created"
			]);

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	}

	include "./add.view.cfm";

</cfscript>
