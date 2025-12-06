<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="attributes.type" type="string";
	param name="attributes.xClass" type="string" default="";
	param name="attributes.xClassToken" type="string" default="";

	icons = {
		close: "svg-sprite--close--18138",
		collections: "svg-sprite--book-flip-page--18271",
		hamburger: "svg-sprite--navigation-menu--18168",
		home: "svg-sprite--house-chimney-2--18112",
		logo: "svg-sprite--mask-heart--18299",
		poems: "svg-sprite--pen-write--18149",
		profile: "svg-sprite--single-neutral-setting--18353",
		sessions: "svg-sprite--network-browser--18218",
	};

	href = icons[ attributes.type ];

	include "./svgIcon.view.cfm";
	exit;

</cfscript>
