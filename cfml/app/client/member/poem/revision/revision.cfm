<cfscript>

	// Define properties for dependency-injection.
	router = request.ioc.get( "core.lib.web.Router" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	// Shared breadcrumb logic for revision entity.
	request.breadcrumbForRevision = breadcrumbForRevision;
	request.breadcrumbForRevisions = breadcrumbForRevisions;

	switch ( router.next( "list" ) ) {
		case "delete":
		case "list":
		case "makeCurrent":
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
	* I provide reusable breadcrumb logic for nested views.
	*/
	private array function breadcrumbForRevision(
		required struct revision,
		required struct position
		) {

		return [ "Revision #position.revisionNumber# of #position.revisionCount#", "member.poem.revision.view", "revisionID", revision.id ];

	}


	/**
	* I provide reusable breadcrumb logic for nested views.
	*/
	private array function breadcrumbForRevisions( required struct poem ) {

		return [ "Revisions", "member.poem.revision", "poemID", poem.id ];

	}

</cfscript>
