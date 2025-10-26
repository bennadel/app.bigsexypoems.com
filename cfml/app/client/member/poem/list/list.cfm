<cfscript>

	listGateway = request.ioc.get( "client.member.poem.list.ListGateway" );
	poemModel = request.ioc.get( "core.lib.model.poem.PoemModel" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	partial = getPartial( authContext = request.authContext );
	poems = partial.poems;
	title = "Poems";

	request.response.title = title;

	include "./list.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial( required struct authContext ) {

		var poems = listGateway.getPoems( authContext.user.id );

		return {
			poems
		};

	}

</cfscript>
