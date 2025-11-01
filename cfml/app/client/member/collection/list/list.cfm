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

	include "./list.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial( required struct authContext ) {

		var collections = CollectionModel
			.getByFilter( userID = authContext.user.id )
			.sort( ( a, b ) => compareNoCase( a.name, b.name ) )
		;

		return {
			collections
		};

	}

</cfscript>
