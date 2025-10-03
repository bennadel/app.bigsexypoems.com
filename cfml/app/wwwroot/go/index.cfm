<cfscript>

	// Define properties for dependency-injection.
	config = request.ioc.get( "config" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	title = request.response.title = "GO Links";

	links = [
		{
			stub: "play",
			description: "Playground poem composer"
		}
	];

</cfscript>
<cfoutput>

	<!doctype html>
	<html lang="en">
	<head>
		<cfmodule template="/client/_shared/tag/meta.cfm">
		<cfmodule template="/client/_shared/tag/title.cfm">
		<cfmodule template="/client/_shared/tag/favicon.cfm">
		<cfmodule template="/client/_shared/tag/bugsnag.cfm">
		<cfmodule template="/client/_shared/tag/opengraph.cfm">

		<!---
			Todo: I should separate out the base CSS so that I can use it in places like
			this where I don't really need a build process. For the moment, I'm just going
			to hijack the auth styles, since those represent non-logged-in experiences.
		--->
		<cfinclude template="/wwwroot/public/main/vendor/vendor.html">
		<cfinclude template="/wwwroot/public/main/auth/auth.html">
		<style type="text/css">
			body {
				margin: 20px auto ;
				max-width: 700px ;
			}
		</style>
	</head>
	<body>

		<h1>
			#e( title )#
		</h1>

		<p>
			This is a directory of short-links to other features within
			<a href="/">#e( config.site.name )#</a>.
		</p>

		<ul>
			<cfloop array="#links#" item="link">
				<li>
					<a href="./#e( link.stub )#"><mark><strong>#e( link.stub )#</strong></mark></a>:
					#e( link.description )#
				</li>
			</cfloop>
		</ul>

	</body>
	</html>

</cfoutput>
