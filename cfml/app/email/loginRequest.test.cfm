<cfscript>

	// Define properties for dependency-injection.
	config = request.ioc.get( "config" );
	router = request.ioc.get( "core.lib.web.Router" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	router.setupRequest();

	partial = {
		subject: "Log into #config.site.name#",
		teaser: "",
		site: {
			name: config.site.name,
			publicUrl: config.site.url
		},
		verification: {
			url: router.externalUrlFor([
				event: "auth.login.verify"
			]),
			expiration: "15 minutes"
		}
	};

	include "./loginRequest.cfm";

</cfscript>
