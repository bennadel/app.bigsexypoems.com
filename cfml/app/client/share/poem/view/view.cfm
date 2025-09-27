<cfscript>

	// Define properties for dependency-injection.
	router = request.ioc.get( "core.lib.web.Router" );
	ui = request.ioc.get( "core.lib.web.UI" );
	userModel = request.ioc.get( "core.lib.model.user.UserModel" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	poem = request.poem;
	share = request.share;
	title = poem.name;
	user = userModel.get( poem.userID );

	lines = poem.content.reMatch( "[^\n]*" );

	request.response.title = title;

	include "./view.view.cfm";

</cfscript>
