<cfscript>

	// Define properties for dependency-injection.
	collectionModel = request.ioc.get( "core.lib.model.collection.CollectionModel" );
	poemAccess = request.ioc.get( "core.lib.service.poem.PoemAccess" );
	poemService = request.ioc.get( "core.lib.service.poem.PoemService" );
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	tagModel = request.ioc.get( "core.lib.model.tag.TagModel" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.poemID" type="numeric";
	param name="form.name" type="string" default="";
	param name="form.content" type="string" default="";
	param name="form.collectionID" type="numeric" default=0;
	param name="form.tagID" type="numeric" default=0;
	param name="form.switchToComposer" type="boolean" default=false;

	partial = getPartial(
		authContext = request.authContext,
		poemID = val( url.poemID )
	);
	poem = partial.poem;
	collections = partial.collections;
	tags = partial.tags;

	title = "Update Poem";
	errorResponse = "";

	request.response.title = title;

	if ( request.isGet ) {

		form.name = poem.name;
		form.content = poem.content;
		form.collectionID = poem.collectionID;
		form.tagID = poem.tagID;

	}

	if ( request.isPost ) {

		try {

			poemService.updatePoem(
				authContext = request.authContext,
				id = poem.id,
				collectionID = val( form.collectionID ),
				tagID = val( form.tagID ),
				name = form.name,
				content = form.content
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

		var collections = collectionModel
			.getByFilter( userID = authContext.user.id )
			.sort( ( a, b ) => compareNoCase( a.name, b.name ) )
		;
		var tags = tagModel
			.getByFilter( userID = authContext.user.id )
			.sort( ( a, b ) => compareNoCase( a.name, b.name ) )
		;

		return {
			poem,
			collections,
			tags
		};

	}

</cfscript>
