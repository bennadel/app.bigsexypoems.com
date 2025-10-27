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
	recentPoems = partial.recentPoems;
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
		var recentPoems = getRecentPoems( poems );

		return {
			poems,
			recentPoems
		};

	}

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I extract the recently updated poems from the given poems.
	*/
	private array function getRecentPoems( required array poems ) {

		var count = 3;

		if ( poems.len() <= count ) {

			return [];

		}

		return arrayCopy( poems )
			.sort(
				( a, b ) => {

					if ( a.updatedAt != b.updatedAt ) {

						return dateCompare( b.updatedAt, a.updatedAt );

					}

					return sgn( b.id - a.id );

				}
			)
			.slice( 1, count )
		;

	}

</cfscript>
