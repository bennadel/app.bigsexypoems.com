<cfscript>

	ui = request.ioc.get( "core.lib.web.UI" );
	userModel = request.ioc.get( "core.lib.model.user.UserModel" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	poem = request.poem;
	title = poem.name;
	user = userModel.get( poem.userID );

	request.response.title = title;

	include "./view.view.cfm";

</cfscript>
