<cfscript>

	// Define properties for dependency-injection.
	shareService = request.ioc.get( "core.lib.service.poem.share.ShareService" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	shareService.logShareViewing( request.share.id );

	// Todo: figure out how to deal with this.
	abort;

</cfscript>
