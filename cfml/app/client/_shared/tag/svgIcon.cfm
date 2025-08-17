<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	param name="attributes.type" type="string";
	param name="attributes.xClass" type="string" default="";
	param name="attributes.xClassToken" type="string" default="";

	icons = {
		"back": "svg-sprite--move-back--18116",
		"home": "svg-sprite--house-chimney-2--18112",
		"logout": "svg-sprite--logout-2--18167",
		"logo": "svg-sprite--mask-heart--18299",
		"poems": "svg-sprite--pen-write--18149",
		"profile": "svg-sprite--single-neutral-setting--18353",
		"sessions": "svg-sprite--network-browser--18218"
	};

	href = icons[ attributes.type ];

	include "./svgIcon.view.cfm";

	// Allow for aesthetic no-op closing tag.
	exit;

</cfscript>
