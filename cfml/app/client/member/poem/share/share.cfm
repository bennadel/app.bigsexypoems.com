<cfscript>

	// Define properties for dependency-injection.
	router = request.ioc.get( "core.lib.web.Router" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// Shared breadcrumb logic for share entity.
	request.breadcrumbForShare = breadcrumbForShare;
	request.breadcrumbForShareLinks = breadcrumbForShareLinks;

	switch ( router.next( "list" ) ) {
		case "add":
		case "delete":
		case "deleteAll":
		case "edit":
		case "list":
		case "view":
		case "viewing":
			cfmodule( template = router.nextTemplate() );
		break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I provide reusable breadcrumb logic for nested views.
	*/
	private array function breadcrumbForShare( required struct share ) {

		return [ share.name, "member.poem.share.view", "shareID", share.id ];

	}


	/**
	* I provide reusable breadcrumb logic for nested views.
	*/
	private array function breadcrumbForShareLinks( required struct poem ) {

		return [ "Share Links", "member.poem.share", "poemID", poem.id ];

	}

</cfscript>
