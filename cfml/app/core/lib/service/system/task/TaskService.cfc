component hint = "I provide workflow methods pertaining to scheduled tasks." {

	// Define properties for dependency-injection.
	property name="httpUtilities" ioc:type="core.lib.util.HttpUtilities";
	property name="ioc" ioc:type="core.lib.util.Injector";
	property name="logger" ioc:type="core.lib.util.Logger";
	property name="scheduledTasks" ioc:get="config.scheduledTasks";
	property name="taskModel" ioc:type="core.lib.model.system.task.TaskModel";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I execute the overdue scheduled task with the given ID.
	*/
	public void function executeOverdueTask(
		required string taskID,
		required string password
		) {

		if ( compare( password, scheduledTasks.password ) ) {

			throw(
				type = "App.ScheduledTasks.IncorrectPassword",
				message = "Scheduled task invoked with incorrect password."
			);

		}

		var task = taskModel.get( taskID );
		var timestamp = utcNow();

		if ( task.nextExecutedAt > timestamp ) {

			return;

		}

		// Make sure overlapping task executions are ignored.
		lock
			name = "TaskService.executeOverdueTask.#task.id#"
			type = "exclusive"
			timeout = 1
			throwOnTimeout = false
			{

			var executor = ioc.get( "core.lib.service.system.task.handler.#task.id#" );

			var startedAt = getTickCount();
			var nextState = ( executor.executeTask( task ) ?: task.state );
			var excuteDuration = ( getTickCount() - startedAt );

			if ( task.isDailyTask ) {

				var lastExecutedAt = utcNow();
				var tomorrow = timestamp.add( "d", 1 );
				var nextExecutedAt = createDateTime(
					year( tomorrow ),
					month( tomorrow ),
					day( tomorrow ),
					hour( task.timeOfDay ),
					minute( task.timeOfDay ),
					second( task.timeOfDay )
				);

			} else {

				var lastExecutedAt = utcNow();
				var nextExecutedAt = lastExecutedAt.add( "n", task.intervalInMinutes );

			}

			taskModel.update(
				id = task.id,
				state = nextState,
				lastExecutedAt = lastExecutedAt,
				nextExecutedAt = nextExecutedAt
			);

			logger.info(
				"Scheduled task executed.",
				[
					taskID: task.id,
					duration: "#numberFormat( excuteDuration )# ms",
					nextState: nextState,
					nextExecutedAt: nextExecutedAt.dateTimeFormat( "iso" )
				]
			);

		} // END: Task lock.

	}


	/**
	* I execute any overdue scheduled tasks.
	*/
	public numeric function executeOverdueTasks() {

		var tasks = taskModel.getByFilter( overdueAt = utcNow() );

		tasks.each(
			( task ) => {

				try {

					makeTaskRequest( task );

				} catch ( any error ) {

					logger.logException( error, "Error making scheduled task request." );

				}

			},
			true // Parallel iteration.
		);

		return tasks.len();

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* Each task is triggered as an individual HTTP request so that it can run in its own
	* context and spawn sub-threads if necessary.
	*/
	private void function makeTaskRequest( required struct task ) {

		// NOTE: We're using a small timeout because we want the tasks to all fire in
		// parallel (as much as possible).
		cfhttp(
			result = "local.httpResponse",
			method = "post",
			url = "#scheduledTasks.url#/index.cfm?event=system.tasks.one",
			timeout = 1
			) {

			// Note: I'm passing the taskID in the URL to make debugging easier.
			cfhttpparam(
				type = "url",
				name = "taskID",
				value = task.id
			);
			cfhttpparam(
				type = "formfield",
				name = "password",
				value = scheduledTasks.password
			);
		}

		var statusCode = httpUtilities.parseStatusCode( httpResponse );
		// For the most part, we're expecting a `408 Request Timeout` to occur since we're
		// not waiting for the individual scheduled tasks to complete execution. However,
		// if the resultant status code is corrupted, it means that the CFHTTP tag was
		// unable to round-trip back to the ColdFusion server. This usually happens if we
		// attempt to connect over HTTPS using an SSL cert that ColdFusion doesn't trust.
		// To fix this, we need to:
		// 
		// 1. Use an `http` URL in order to avoid certificate issues.
		// 
		// 2. Ensure that we have a `hosts` entry so the request doesn't leave the server,
		//    but can still hit the correct host in IIS.
		if ( ! statusCode.ok && ( statusCode.code != 408 ) ) {

			throw(
				type = "UnexpectedStatusCode",
				message = "Possible connection failure.",
				extendedInfo = serializeJson( statusCode )
			);

		}

	}

}
