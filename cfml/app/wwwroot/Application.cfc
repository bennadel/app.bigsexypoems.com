component
	output = false
	hint = "I define the application settings and event handlers."
	{

	// Define the application settings.
	this.name = "AppBigSexyPoemsCom";
	this.applicationTimeout = createTimeSpan( 7, 0, 0, 0 );
	this.sessionManagement = false;
	this.setClientCookies = false;
	// As a security best practice, we DO NOT WANT to search for unscoped variables in any
	// scope other than the core variables, local, and arguments scope. The CGI, FORM,
	// URL, COOKIE, etc. should only ever be referenced explicitly.
	this.searchImplicitScopes = false;
	// Make sure that every struct key-case matches its original defining context. This
	// way, we don't get any unexpected upper-casing of keys (a legacy CFML behavior).
	this.serialization = {
		preserveCaseForStructKey: true,
		preserveCaseForQueryColumn: true
	};
	// Make sure that all arrays are passed by reference. Historically, arrays have been
	// passed by value, which has no place in a modern language.
	this.passArrayByReference = true;
	// Stop ColdFusion from replacing "<script>" tags with "InvalidTag". This doesn't
	// really help us out.
	this.scriptProtect = "none";
	// Block all file extensions by default. This will require each fileUpload() call to
	// have an explicit set of allow-listed mime-types.
	this.blockedExtForFileUpload = "*";

	// Define the server mappings (for components and expandPath() calls).
	this.directory = getDirectoryFromPath( getCurrentTemplatePath() );
	this.approot = "#this.directory#..";
	this.mappings = [
		"/": this.approot,
		"/client": "#this.approot#/client",
		"/config": "#this.approot#/config",
		"/core": "#this.approot#/core",
		"/db": "#this.approot#/db",
		"/email": "#this.approot#/email",
		"/log": "#this.approot#/log",
		"/upload": "#this.approot#/upload",
		"/wwwroot": "#this.approot#/wwwroot"
	];

	// Load the configuration file (caution: uses mappings defined above).
	this.config = getConfigSettings();

	// Define the data-sources. The data-source names are CASE-SENSITIVE and need to be
	// quoted.
	this.datasource = "bigsexypoems";
	this.datasources = {
		"#this.datasource#": buildMySqlDatasource( this.config.datasource )
	};

	// Define to mail server settings.
	this.smtpServerSettings = this.config.smtp;

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* I get called once when the application is being bootstrapped. This method is
	* inherently single-threaded by the ColdFusion application server. However, if this is
	* called as part of an explicit re-initialization, then it will not be single threaded
	* and concurrent traffic needs to be considered.
	*/
	public void function onApplicationStart() {

		var ioc
			= application.ioc
				= new core.lib.util.Injector()
		;
		// Register the IoC Injector with itself so that it can be injected into other
		// components (for some rare meta-programming).
		ioc.provide( "core.lib.util.Injector", ioc );

		var config
			= this.config
				= application.config
					= ioc.provide( "config", getConfigSettings( useCacheConfig = false ) )
		;

		cfschedule(
			action = "update",
			task = "Task Runner",
			group = "BigSexyPoems",
			mode = "application",
			operation = "HTTPRequest",
			url = "#config.scheduledTasks.url#/index.cfm?event=system.tasks.all",
			startDate = "1970-01-01",
			startTime = "00:00 AM",
			interval = 60 // Every 60-seconds.
		);

		// As the very last step in the initialization process, we want to flag that the
		// application has been fully bootstrapped. This way, we can test the state of the
		// application in the global onError() event handler.
		application.isBootstrapped = true;

	}


	/**
	* I get called once to initialize the request.
	*/
	public void function onRequestStart() {

		if ( url?.init == this.config.initPassword ) {

			this.onApplicationStart();

			// In the production app, redirect to the non-init page so that we don't run
			// the risk of re-initializing the application more often than we have to.
			if ( this.config.isLive ) {

				location( url = cgi.script_name, addToken = false );

			}

		}

		// By default, we want the request timeout to be relatively low so that we lock
		// page processing down. This means that we have to make a cognizant choice to
		// create slow(er) pages later on by explicitly extending the timeout.
		cfsetting(
			requestTimeout = 5,
			showDebugOutput = false
		);

		request.ioc = application.ioc;

		// Polyfill the Lucee CFML behavior in which "field[]" notation causes multiple
		// fields (form or url) to be grouped together as an array. This is the way.
		request.ioc.get( "core.lib.web.ParameterGroupingPolyfill" )
			.apply()
		;

	}


	/**
	* I get called once to finalize the request.
	*/
	public void function onRequestEnd() {

		if ( this.config.isLive ) {

			return;

		}

		// Since the memory leak detection only runs in the development environment, I'm
		// not going to put any safe-guards around it. The memory leak detector both reads
		// from and writes to shared memory, which can be inherently unsafe. However, the
		// risks here are minimal.
		// --
		// Note: In the case of a memory leak, a warning is written to standard out.
		request.ioc.get( "core.lib.util.MemoryLeakDetector" )
			.inspect()
		;

	}


	/**
	* I handle uncaught errors within the application.
	*/
	public void function onError(
		required any exception,
		string eventName = ""
		) {

		// Override the request timeout so that we have time to handle any errors.
		cfsetting( requesttimeout = ( 60 * 5 ) );

		var error = ( exception.rootCause ?: exception.cause ?: exception );

		// At this point, we have no idea where in the application life-cycle the error
		// was thrown. We don't even know if the IoC container exists or if the logger
		// could be created (and, if created, is it bug-free). As such, we're going to try
		// using the logger and, if it fails, we'll fallback to using a file-based log.
		try {

			application.ioc
				.get( "core.lib.util.Logger" )
				.logException( error )
			;

		} catch ( any loggingError ) {

			// The core logger failed, falling back to using a file-based logger so at
			// least we don't lose critical error information.
			var logDirectory = this.mappings[ '/log' ];
			var logFileStub = now().dateTimeFormat( "yyyy-mm-dd-HH-nn-ss-l" );

			writeDump(
				var = loggingError,
				format = "text",
				output = "#logDirectory#/#logFileStub#-try.txt"
			);
			writeDump(
				var = error,
				format = "text",
				output = "#logDirectory#/#logFileStub#-original.txt"
			);

		}

		// If the bootstrapping flag is null, it means that the application failed to
		// fully initialize. However, we can't be sure where in the process the error
		// occurred, so we want to just stop the application and let the next inbound
		// request re-trigger the application start-up.
		if ( isNull( application.isBootstrapped ) ) {

			cfheader( statusCode = 503 );
			writeOutput( "<h1> Service Unavailable </h1>" );
			writeOutput( "<p> Please try back in a few minutes. </p>" );

			// If the application isn't actually running yet, attempting to stop it will
			// throw an error.
			try {

				applicationStop();

			} catch ( any stopError ) {

				// Swallow error, let next request start application.

			}

			return;

		}

		// Check to see if we are live or not. If we are live then we want to display the
		// user-friendly error page. However, if we're not live, then we want to render
		// the error for debugging.
		// --
		// Note: remember that this onError() event handler is only for errors that aren't
		// caught by the application logic.
		if ( ! this.config.isLive ) {

			// We are local, dump the error out for debugging.
			cfheader( statusCode = 500 );
			writeDump( var = exception, top = 5 );
			abort;

		}

		// Since we don't know where exactly the error occurred, it's possible that the
		// request has been flushed already or is in an entirely unusable state. As such,
		// the best we can do is just show a vanilla error message.
		writeOutput( "An unexpected error occurred." );
		abort;

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I build the settings object for a MySQL datasource with the given datasource object.
	*/
	private struct function buildMySqlDatasource( required struct datasource ) {

		return {
			username: datasource.username,
			password: datasource.password,
			driver: "MySQL",
			class: "com.mysql.cj.jdbc.Driver",
			url: (
				"jdbc:mysql://#datasource.server#:#datasource.port#/#datasource.database#" &
				"?allowMultiQueries=true" &
				"&characterEncoding=UTF-8" &
				"&serverTimezone=UTC" &
				"&tinyInt1isBit=false" &
				// Max Performance properties: https://github.com/mysql/mysql-connector-j/blob/release/8.0/src/main/resources/com/mysql/cj/configurations/maxPerformance.properties
				"&useConfigs=maxPerformance"
				// NOTE: Leaving zeroDateTimeBehavior as default (EXCEPTION) since I don't
				// like the idea of any data/times values being shoe-horned into a working
				// version. I'd rather see the errors and then deal with them.
			),

			// Allowed SQL commands.
			delete: true,
			insert: true,
			select: true,
			update: true,

			// Disallowed SQL commands.
			alter: false,
			create: false,
			drop: false,
			grant: false,
			revoke: false,
			storedproc: false,

			// Disables the returning of generated keys (such as PKEY AUTO_INCREMENT) in
			// the "result" meta-data structure.
			disable_autogenkeys: false,

			// These two properties seem to work in conjunction and limit the size of the
			// long-text fields that can be PULLED BACK FROM THE DATABASE. If the CLOB is
			// disabled, then the given buffer size will truncate the value coming back
			// from the database.
			// --
			// Note: To be clear, this DOES NOT appear to prevent the INSERT of large
			// values GOING INTO the database - just the retrieval of large values coming
			// OUT OF the database.
			disable_clob: false,
			buffer: 0, // Doesn't mean anything unless above is TRUE.

			// I ASSUME these two properties for BLOB work the same way as the CLOB
			// settings above; but, I have not tested them directly.
			disable_blob: true,
			blob_buffer: 64000, // Doesn't mean anything unless above is TRUE.

			// Connection pooling.
			// --
			// Caution: I have NOT VALIDATED that the following settings actually work
			// (except for the urlmap.maxConnection property).
			pooling: true,
			// The number of seconds before ColdFusion times out the data source
			// connection login attempt.
			login_timeout: 30,
			// The number of seconds that ColdFusion maintains an unused connection before
			// destroying it.
			timeout: 1200,
			// The number of seconds that the server waits between cycles to check for
			// expired data source connections to close.
			interval: 420
			// urlmap: {
			// 	// Limit the number of concurrent connections to this datasource.
			// 	// --
			// 	// Caution: This value has to be a STRING - if you use a NUMBER, the
			// 	// entire datasource configuration will fail. And, if you don't want to
			// 	// limit connection, you have to OMIT THIS VALUE ENTIRELY.
			// 	// --
			// 	// maxConnections: ""
			// }
		};

	}


	/**
	* I return the application's environment-specific config object. The config object is
	* cached in the server scope using "this.name" as part of the access key.
	*/
	private struct function getConfigSettings( boolean useCacheConfig = true ) {

		var cacheKey = "appConfig_#this.name#";

		if ( useCacheConfig && server.keyExists( cacheKey ) ) {

			return server[ cacheKey ];

		}

		var config
			= server[ cacheKey ]
				= deserializeJson( fileRead( this.mappings[ "/config" ] & "/config.json" ) )
		;

		return config;

	}

}
