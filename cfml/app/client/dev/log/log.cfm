<cfscript>

	// Define properties for dependency-injection.
	devLogs = request.ioc.get( "core.lib.util.DevLogs" );
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="form.deleteLogs" type="string" default="";

	partial = getPartial();
	entries = partial.entries;

	title = "Local Development Logs";
	errorResponse = "";

	request.response.title = title;

	if ( request.isPost && ( form.deleteLogs == "true" ) ) {

		try {

			devLogs.deleteAll();

			router.goto([
				event: "dev.log"
			]);

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	}

	include "./log.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial() {

		var entries = devLogs.getAll();

		return {
			entries,
		};

	}

</cfscript>
