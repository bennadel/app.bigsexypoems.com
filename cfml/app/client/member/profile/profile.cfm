<cfscript>

	// Define properties for dependency-injection.
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	themeService = request.ioc.get( "core.lib.service.user.ThemeService" );
	ui = request.ioc.get( "core.lib.web.UI" );
	userModel = request.ioc.get( "core.lib.model.user.UserModel" );
	userService = request.ioc.get( "core.lib.service.user.UserService" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="form.name" type="string" default="";
	param name="form.theme" type="string" default="";

	partial = getPartial( request.authContext );
	user = partial.user;
	theme = partial.theme;
	themes = partial.themes;
	title = "Profile";
	errorResponse = "";

	request.response.title = title;
	request.response.activeNav = "profile";
	request.response.breadcrumbs.append([ "Home", "member.home" ]);
	request.response.breadcrumbs.append([ "Profile", "member.profile" ]);

	if ( request.isGet ) {

		form.name = user.name;
		form.theme = theme.id;

	}

	if ( request.isPost ) {

		try {

			themeService.setTheme( form.theme );

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

		var user = authContext.user;
		var theme = themeService.getTheme();
		var themes = themeService.getThemes();

		return {
			user,
			theme,
			themes,
		};

	}

</cfscript>
