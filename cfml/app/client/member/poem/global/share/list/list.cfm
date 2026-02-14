<cfscript>

	// Define properties for dependency-injection.
	listGateway = request.ioc.get( "client.member.poem.global.share.list.ListGateway" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	partial = getPartial( authContext = request.authContext );
	shares = partial.shares;

	request.response.title = title = "All Shares Across All Poems";
	request.response.breadcrumbs.append( "Share Links" );

	include "./list.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial( required struct authContext ) {

		var shares = listGateway.getShares( authContext.user.id );

		return {
			shares
		};

	}

</cfscript>
