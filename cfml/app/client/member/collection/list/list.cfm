<cfscript>

	collectionModel = request.ioc.get( "core.lib.model.collection.CollectionModel" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	partial = getPartial( authContext = request.authContext );
	collections = partial.collections;
	title = "Collections";

	request.response.title = title;
	// Note: no terminal breadcrumb for default views.

	include "./list.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial( required struct authContext ) {

		var collections = CollectionModel.getByFilter(
			userID = authContext.user.id,
			withSort = "name"
		);

		return {
			collections
		};

	}

</cfscript>
