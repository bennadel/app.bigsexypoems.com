<cfscript>

	// Define properties for dependency-injection.
	config = request.ioc.get( "config" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	if ( config.isLive ) {

		abort;

	}

	include "/email/team/invitation/invitation.test.cfm";
	include "/email/conceptBoardComment.test.cfm";
	include "/email/loginRequest.test.cfm";

</cfscript>
