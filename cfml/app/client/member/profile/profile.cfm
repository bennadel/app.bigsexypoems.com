<cfscript>

	// Define properties for dependency-injection.
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	ui = request.ioc.get( "core.lib.web.UI" );
	userModel = request.ioc.get( "core.lib.model.user.UserModel" );
	userService = request.ioc.get( "core.lib.service.user.UserService" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="form.name" type="string" default="";

	partial = getPartial( request.authContext );
	user = partial.user;
	title = "Profile";
	errorResponse = "";

	request.response.title = title;
	request.response.activeNav = "profile";
	request.response.breadcrumbs.append([ "Home", "member.home" ]);
	request.response.breadcrumbs.append([ "Profile", "member.profile" ]);

	if ( request.isGet ) {

		form.name = user.name;

	}

	if ( request.isPost ) {

		try {

			userService.update(
				authContext = request.authContext,
				id = request.authContext.user.id,
				name = form.name
			);

			router.goto([
				event: "member.profile",
				flash: "your.user.account.updated"
			]);

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	}

	include "./profile.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial( required struct authContext ) {

		return {
			user: authContext.user
		};

	}

</cfscript>
