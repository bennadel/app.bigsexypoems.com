<cfscript>

	// Define properties for dependency-injection.
	listGateway = request.ioc.get( "client.member.poem.shareAll.list.ListGateway" );
	shareAccess = request.ioc.get( "core.lib.service.poem.share.ShareAccess" );
	// shareModel = request.ioc.get( "core.lib.model.poem.share.ShareModel" );
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

		// Todo: how do I handle security for this via the "access" component model?
		// There's no parent context to hook into (ie, no specific poem or share that I
		// can use to verify access. So, I'd have to ask something if I can see shares
		// across "anything". Might just mean I need a special method for that.
		// .... shareAccess.something();

		var results = listGateway.getShares( authContext.user.id );
		var poems = [];
		var poem = { id: 0 };

		for ( var result in results ) {

			if ( result.poem_id != poem.id ) {

				poem = {
					id: result.poem_id,
					name: result.poem_name,
					shares: []
				};
				poems.append( poem );

			}

			poem.shares.append({
				id: result.share_id,
				token: result.share_token,
				name: result.share_name,
				noteMarkdown: result.share_noteMarkdown,
				viewingCount: result.share_viewingCount,
				createdAt: result.share_createdAt
			});

		}

		return {
			poems
		};

	}

</cfscript>
