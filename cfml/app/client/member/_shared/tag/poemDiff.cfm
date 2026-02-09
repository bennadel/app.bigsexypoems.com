<cfscript>

	// Define properties for dependency-injection.
	poemDiffService = request.ioc.get( "core.lib.service.poem.PoemDiff" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="attributes.originalName" type="string";
	param name="attributes.originalContent" type="string";
	param name="attributes.modifiedName" type="string";
	param name="attributes.modifiedContent" type="string";
	param name="attributes.xClass" type="string" default="";
	param name="attributes.xClassToken" type="string" default="";

	splitRows = poemDiffService.getSplitRows(
		originalName = attributes.originalName,
		originalContent = attributes.originalContent,
		modifiedName = attributes.modifiedName,
		modifiedContent = attributes.modifiedContent
	);

	include "./poemDiff.view.cfm";
	exit;

</cfscript>
