<cfscript>

	// Define properties for dependency-injection.
	router = request.ioc.get( "core.lib.web.Router" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="request.response.title" type="string";
	param name="request.response.body" type="string";
	param name="request.response.activeNav" type="string" default="";
	param name="request.response.breadcrumbs" type="array" default=[];

	user = request.authContext.user;
	breadcrumbs = normalizeBreadcrumbs( request.response.breadcrumbs );

	// Include common HTTP response headers.
	cfmodule( template = "/client/_shared/layout/http/headers.cfm" );
	cfmodule( template = "/client/_shared/layout/http/headersForHtmx.cfm" );

	// Reset the output buffer.
	cfcontent( type = "text/html; charset=utf-8" );

	include "./default.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* For ease of creation, the breadcrumbs get created as sets of router URL Parts. The
	* normalization converts it all to links for rendering.
	*/
	private array function normalizeBreadcrumbs( required array breadcrumbs ) {

		return breadcrumbs.map(
			( element, i, collection ) => {

				// If the element is a string, assume it's the name of a breadcrumb that
				// has no link. This is a convenience so that the calling context doesn't
				// have to allocate the array just to pass-in the name.
				if ( isSimpleValue( element ) ) {

					element = [ element ];

				}

				var isLast = ( i == collection.len() );
				var text = truncate( element.shift(), 30 );
				var href = element.len()
					? router.urlForParts( argumentCollection = element )
					: ""
				;

				return {
					text,
					href,
					isLast,
				};

			}
		);

	}

</cfscript>
