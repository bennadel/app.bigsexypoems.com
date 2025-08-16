<cfscript>

	flashTranslator = request.ioc.get( "core.lib.web.FlashTranslator" );
	logger = request.ioc.get( "core.lib.util.Logger" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="attributes.xClass" type="string" default="";
	param name="attributes.xClassToken" type="string" default="";

	flashToken = ( url.flash ?: "" );
	flashData = ( url.flashData ?: "" );

	if ( ! flashToken.len() ) {

		exit;

	}

	flashResponse = flashTranslator.translate( flashToken, flashData );

	include "./flashMessage.view.cfm";

</cfscript>
