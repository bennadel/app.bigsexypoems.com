<cfscript>

	// Define properties for dependency-injection.
	router = request.ioc.get( "core.lib.web.Router" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	request.response.activeNav = "poems";
	request.response.breadcrumbs.append([ "Home", "member.home" ]);
	request.response.breadcrumbs.append([ "Poems", "member.poem" ]);
	// Shared breadcrumb logic for poem entity.
	request.breadcrumbForPoem = breadcrumbForPoem;

	switch ( router.next( "list" ) ) {
		case "add":
		case "composer":
		case "delete":
		case "edit":
		case "global":
		case "list":
		case "share":
		case "view":
			cfmodule( template = router.nextTemplate() );
		break;
		default:
			throw( type = "App.Routing.InvalidEvent" );
		break;
	}

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I provide reusable poem-to-breadcrumb logic for nested views.
	*/
	private array function breadcrumbForPoem( required struct poem ) {

		return [ poem.name, "member.poem.view", "poemID", poem.id ];

	}

</cfscript>
