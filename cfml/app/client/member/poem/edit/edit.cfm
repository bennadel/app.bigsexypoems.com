<cfscript>

	// Define properties for dependency-injection.
	collectionModel = request.ioc.get( "core.lib.model.collection.CollectionModel" );
	poemAccess = request.ioc.get( "core.lib.service.poem.PoemAccess" );
	poemService = request.ioc.get( "core.lib.service.poem.PoemService" );
	revisionService = request.ioc.get( "core.lib.service.poem.revision.RevisionService" );
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
	param name="form.collectionID" type="numeric" default=0;
	param name="form.switchToComposer" type="boolean" default=false;

	partial = getPartial(
		authContext = request.authContext,
		poemID = val( url.poemID )
	);
	poem = partial.poem;
	collections = partial.collections;

	title = "Update Poem";
	errorResponse = "";

	request.response.title = title;
	request.response.breadcrumbs.append( request.breadcrumbForPoem( poem ) );
	request.response.breadcrumbs.append( "Edit" );

	if ( request.isGet ) {

		form.name = poem.name;
		form.content = poem.content;
		form.collectionID = poem.collectionID;

	}

	if ( request.isPost ) {

		try {

			poemService.update(
				authContext = request.authContext,
				id = poem.id,
				collectionID = val( form.collectionID ),
				name = form.name,
				content = form.content
			);

			revisionService.saveRevision(
				poemID = poem.id,
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

		return {
			poem,
			collections,
		};

	}

</cfscript>
