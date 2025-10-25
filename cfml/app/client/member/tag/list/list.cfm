<cfscript>

	tagModel = request.ioc.get( "core.lib.model.tag.TagModel" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	partial = getPartial( authContext = request.authContext );
	tags = partial.tags;
	title = "Tags";

	request.response.title = title;

	include "./list.view.cfm";

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
