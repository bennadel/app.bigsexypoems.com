<cfscript>

	// Define properties for dependency-injection.
	poemService = request.ioc.get( "core.lib.service.poem.PoemService" );
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	tagModel = request.ioc.get( "core.lib.model.tag.TagModel" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.importFrom" type="string" default="";
	param name="form.name" type="string" default="";
	param name="form.content" type="string" default="";
	param name="form.tagID" type="numeric" default=0;
	param name="form.switchToComposer" type="boolean" default=false;

	partial = getPartial( authContext = request.authContext );
	tags = partial.tags;

	title = url.importFrom.len()
		? "Import Poem From Playground"
		: "Create New Poem"
	;
	cancelToEvent = url.importFrom.len()
		? "playground"
		: "member.poem"
	;
	errorResponse = "";

	request.response.title = title;

	if ( request.isPost ) {

		// If the user is switching to the composer experience, we need to ensure that the
		// poem has a name (since this is a required field). If there's no name, we'll
		// just use a generic one that they can change once in the composer.
		if ( form.switchToComposer ) {

			form.name = coalesceTruthy( form.name, "New Poem at #ui.userTime( utcNow() )#" );

		}

		try {

			poemID = poemService.createPoem(
				authContext = request.authContext,
				userID = request.authContext.user.id,
				poemTagID = val( form.tagID ),
				poemName = form.name,
				poemContent = form.content
			);

			if ( form.switchToComposer ) {

				router.goto([
					event: "member.poem.composer",
					poemID: poemID
				]);

			}

			router.goto([
				event: "member.poem.view",
				poemID: poemID,
				flash: "your.poem.created"
			]);

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	}

	include "./add.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial( required struct authContext ) {

		var tags = tagModel
			.getByFilter( userID = authContext.user.id )
			.sort( ( a, b ) => compareNoCase( a.name, b.name ) )
		;

		return {
			tags
		};

	}

</cfscript>
