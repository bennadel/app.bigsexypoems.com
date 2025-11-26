<cfscript>

	// Define properties for dependency-injection.
	router = request.ioc.get( "core.lib.web.Router" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	request.response.activeNav = "collections";
	request.response.breadcrumbs.append([ "Home", "member.home" ]);
	request.response.breadcrumbs.append([ "Collections", "member.collection" ]);
	// Shared breadcrumb logic for collection entity.
	request.breadcrumbForCollection = breadcrumbForCollection;

	switch ( router.next( "list" ) ) {
		case "add":
		case "delete":
		case "edit":
		case "list":
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
	* I provide reusable collection-to-breadcrumb logic for nested views.
	*/
	private array function breadcrumbForCollection( required struct collection ) {

		return [ collection.name, "member.collection.view", "collectionID", collection.id ];

	}

</cfscript>
