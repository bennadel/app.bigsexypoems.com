<cfscript>

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="request.response.contentDisposition" type="string" default="attachment";
	param name="request.response.etag" type="string" default="";
	param name="request.response.maxAgeInDays" type="numeric" default=0;
	param name="request.response.mimeType" type="string" default="application/octet-stream";
	param name="request.response.filename" type="string";
	param name="request.response.body" type="binary";

	// Include common HTTP response headers.
	cfmodule( template = "./http/headers.cfm" );

	if ( request.response.etag.len() ) {

		cfheader(
			name = "ETag",
			value = request.response.etag
		);

	}

	if ( request.response.maxAgeInDays ) {

		cfheader(
			name = "Cache-Control",
			value = "max-age=#getMaxAge( request.response.maxAgeInDays )#"
		);

	}

	cfheader(
		name = "Content-Length",
		value = arrayLen( request.response.body )
	);

	if ( request.response.contentDisposition == "attachment" ) {

		cfheader(
			name = "Content-Disposition",
			value = "#request.response.contentDisposition#; filename=""#e4u( request.response.filename )#""; filename*=UTF-8''#e4u( request.response.filename )#"
		);

	}

	// Reset the output buffer.
	cfcontent(
		type = request.response.mimeType,
		variable = request.response.body
	);

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the number of seconds for the max-age of the given day-span.
	*/
	private numeric function getMaxAge( required numeric maxAgeInDays ) {

		var perMinute = 60;
		var perHour = ( 60 * perMinute );
		var perDay = ( 24 * perHour );

		return ( maxAgeInDays * perDay );

	}

</cfscript>
