<cfscript>

	// Define properties for dependency-injection.
	listGateway = request.ioc.get( "client.member.poem.global.share.list.ListGateway" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	partial = getPartial( authContext = request.authContext );
	poems = partial.poems;

	request.response.title = title = "All Shares Across All Poems";

	include "./list.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial( required struct authContext ) {

		var results = listGateway.getShares( authContext.user.id );
		var poems = [];
		var poem = { id: 0 };

		for ( var result in results ) {

			if ( result.poem.id != poem.id ) {

				poem = result.poem;
				poem.shares = [];
				poems.append( poem );

			}

			poem.shares.append( result.share );

		}

		return {
			poems
		};

	}

</cfscript>
