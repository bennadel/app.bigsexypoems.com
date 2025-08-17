<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	config = request.ioc.get( "config" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	title = "Login Request Sent";
	localDevInbox = "";
	localDevLoginUrl = "";

	// In order to make local development a little less tedious, I want to make the link-
	// based login workflow actionable immediately instead of forcing the email workflow.
	if ( ! config.isLive ) {

		localDevInbox = "http://127.0.0.1:8025";
		localDevLoginUrl = ( cookie.loginUrlForLocalDevelopment ?: "" );

		cookie.loginUrlForLocalDevelopment = {
			value: "",
			expires: "now"
		};

	}

	request.response.title = title;

	include "./sent.view.cfm";

</cfscript>
