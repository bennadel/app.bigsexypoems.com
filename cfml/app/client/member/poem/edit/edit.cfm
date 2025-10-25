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
	param name="form.name" type="string" default="";
	param name="form.content" type="string" default="";
	param name="form.tagID" type="numeric" default=0;
	param name="form.switchToComposer" type="boolean" default=false;

	partial = getPartial(
		authContext = request.authContext,
		poemID = val( url.poemID )
	);
	poem = partial.poem;

	title = "Update Poem";
	errorResponse = "";

	request.response.title = title;

	if ( request.isGet ) {

		form.name = poem.name;
		form.content = poem.content;
		form.tagID = poem.tagID;

	}

	if ( request.isPost ) {

		try {

			poemService.updatePoem(
				authContext = request.authContext,
				poemID = poem.id,
				poemTagID = val( form.tagID ),
				poemName = form.name,
				poemContent = form.content
			);

			if ( form.switchToComposer ) {

				router.goto([
					event: "member.poem.composer",
					poemID: poem.id
				]);

			}

			router.goto([
				event: "member.poem.view",
				poemID: poem.id,
				flash: "your.poem.updated"
			]);

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	}

	include "./edit.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial(
		required struct authContext,
		required numeric poemID
		) {

		var context = poemAccess.getContext( authContext, poemID, "canUpdate" );
		var poem = context.poem;

		return {
			poem
		};

	}

</cfscript>
