<cfscript>

	// Define properties for dependency-injection.
	revisionAccess = request.ioc.get( "core.lib.service.poem.RevisionAccess" );
	revisionModel = request.ioc.get( "core.lib.model.poem.RevisionModel" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.poemID" type="numeric";

	partial = getPartial(
		authContext = request.authContext,
		poemID = val( url.poemID )
	);
	poem = partial.poem;
	revisions = partial.revisions;
	title = poem.name;

	request.response.title = title;
	request.response.breadcrumbs.append( request.breadcrumbForPoem( poem ) );
	request.response.breadcrumbs.append( request.breadcrumbForRevisions( poem ) );
	// Note: no terminal breadcrumb for default views.

	include "./list.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial(
		required struct authContext,
		required numeric poemID
		) {

		var context = revisionAccess.getContextForParent( authContext, poemID, "canViewAny" );
		var poem = context.poem;
		var revisions = revisionModel.getByFilter(
			poemID = poem.id,
			withSort = "newest"
		);

		return {
			poem,
			revisions
		};

	}

</cfscript>
