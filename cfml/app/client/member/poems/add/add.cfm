<cfscript>

	poemService = request.ioc.get( "core.lib.service.poem.PoemService" );
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="form.name" type="string" default="";
	param name="form.content" type="string" default="";

	title = "Create New Poem";
	errorResponse = "";

	request.response.title = title;

	if ( form.submitted ) {

		try {

			poemID = poemService.createPoem(
				authContext = request.authContext,
				userID = request.authContext.user.id,
				poemName = form.name.trim(),
				poemContent = form.content.trim()
			);

			router.goto([
				event: "member.poems.view",
				poemID: poemID,
				flash: "member.poem.created"
			]);

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	}

	include "./add.view.cfm";

</cfscript>
