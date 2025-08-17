component
	output = false
	hint = "I implement the logging interface and send data to the BugSnag API."
	{

	// Define properties for dependency-injection.
	property name="apiClient" ioc:type="core.lib.integration.bugsnag.BugSnagApiClient";
	property name="config" ioc:type="config";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I log the given data as a pseudo-exception (ie, we're shoehorning general log data
	* into a bug log tracking system since I don't have a logging system outside of error
	* tracking - gotta leverage those free tiers as much as I can).
	*/
	public void function logData(
		required string level,
		required string message,
		required any data,
		required array stacktrace,
		required struct requestContext
		) {

		// Note: Normally, the errorClass represents an "error type". However, in this
		// case, since we don't have an error to log, we're going to use the message as
		// the grouping value. This makes sense since these are developer-provided
		// messages and will likely be unique in nature.
		sendToBugSnag({
			exceptions: [
				{
					errorClass: message,
					message: "#level# log entry",
					stacktrace: stacktrace,
					type: "coldfusion"
				}
			],
			request: {
				clientIp: requestContext.http.remoteAddress,
				headers: requestContext.http.headers,
				httpMethod: requestContext.http.method,
				url: requestContext.http.url,
				referer: requestContext.http.referer
			},
			context: requestContext.event,
			severity: buildSeverity( level ),
			app: {
				releaseStage: config.bugsnag.server.releaseStage
			},
			metaData:{
				urlScope: requestContext.urlScope,
				formScope: requestContext.formScope,
				data: data
			}
		});

	}


	/**
	* I report the given EXCEPTION object using an ERROR log-level.
	*/
	public void function logException(
		required struct error,
		required string message,
		required any data,
		required array stacktrace,
		required struct requestContext
		) {

		sendToBugSnag({
			exceptions: [
				{
					errorClass: error.type,
					message: buildExceptionMessage( message, error ),
					stacktrace: stacktrace,
					type: "coldfusion"
				}
			],
			request: {
				clientIp: requestContext.http.remoteAddress,
				headers: requestContext.http.headers,
				httpMethod: requestContext.http.method,
				url: requestContext.http.url,
				referer: requestContext.http.referer
			},
			context: requestContext.event,
			severity: "error",
			app: {
				releaseStage: config.bugsnag.server.releaseStage
			},
			metaData:{
				urlScope: requestContext.urlScope,
				formScope: requestContext.formScope,
				data: data,
				error: error
			}
		});

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I build the log message for the given exception.
	*/
	private string function buildExceptionMessage(
		required string message,
		required struct error
		) {

		if ( message.len() ) {

			return message;

		}

		return error.message;

	}


	/**
	* I build the event severity data.
	*
	* Note: On the BugSnag side, the "level" information is a limited enum. As such, we
	* have to shoe-horn some of our internal level-usage into their finite set.
	*/
	private string function buildSeverity( required string level ) {

		switch ( level ) {
			case "fatal":
			case "critical":
			case "error":
				return "error";
			break;
			case "warning":
				return "warning";
			break;
			default:
				return "info";
			break;
		}

	}


	/**
	* I notify the BugSnag API about the given event using an async thread. Any errors
	* caught within the thread will be written to the error log.
	*/
	private void function sendToBugSnag( required struct notifyEvent ) {

		// In Adobe ColdFusion, you can't have nested threads. So, we have to see if we're
		// in a current thread context before we try to spawn the remote API thread.
		if ( isInThread() ) {

			sendToBugSnagSafely( notifyEvent );
			return;

		}

		thread
			name = "BugSnagLogger.sendToBugSnag.#createUuid()#"
			notifyEvent = notifyEvent
			{

			sendToBugSnagSafely( notifyEvent );

		}

	}


	/**
	* I notify the BugSnag API using a safe, synchronous mechanism. Any errors thrown here
	* are logged to the log file.
	*/
	private void function sendToBugSnagSafely( required struct notifyEvent ) {

		try {

			apiClient.notify([ notifyEvent ]);

		} catch ( any error ) {

			writeLog(
				type = "error",
				log = "Application",
				text = "[#error.type#]: #error.message#"
			);

		}

	}

}
