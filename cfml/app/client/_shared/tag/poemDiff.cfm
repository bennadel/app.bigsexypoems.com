<cfscript>

	// Define properties for dependency-injection.
	myersDiff = request.ioc.get( "core.lib.util.MyersDiff" );
	poemService = request.ioc.get( "core.lib.service.poem.PoemService" );

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

	// Prepend title as first line so title changes appear in the diff naturally.
	originalLines = poemService.splitLines( attributes.originalContent );
	originalLines.prepend( "---" );
	originalLines.prepend( attributes.originalName );

	modifiedLines = poemService.splitLines( attributes.modifiedContent );
	modifiedLines.prepend( "---" );
	modifiedLines.prepend( attributes.modifiedName );

	lineDiff = myersDiff.diffElements(
		original = originalLines,
		modified = modifiedLines
	);

	// Add word-level tokens for single-line mutations.
	diffOperations = myersDiff.tokenizeOperations( lineDiff.operations );

	include "./poemDiff.view.cfm";
	exit;

</cfscript>
