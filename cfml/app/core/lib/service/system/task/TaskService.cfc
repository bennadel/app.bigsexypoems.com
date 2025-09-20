component hint = "I provide workflow methods pertaining to scheduled tasks." {

	// Define properties for dependency-injection.
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

			var nextState = ioc
				.get( "core.lib.service.system.task.handler.#task.id#" )
				.executeTask( task )
			;

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
				state = ( nextState ?: task.state ),
				lastExecutedAt = lastExecutedAt,
				nextExecutedAt = nextExecutedAt
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
			result = "local.results",
			method = "post",
			url = "#scheduledTasks.url#/index.cfm?event=system.tasks.one",
			timeout = 1
			) {

			cfhttpparam(
				type = "formfield",
				name = "taskID",
				value = task.id
			);
			cfhttpparam(
				type = "formfield",
				name = "password",
				value = scheduledTasks.password
			);
		}

		// Todo: it might be worth logging failed requests here. This should only ever
		// happen if the network requests fail (such as an unreachable domain or an
		// unsupported SSL certificate). However, once the tasks have been demonstrated
		// to be working, they shouldn't suddenly fail. As such, I'm going to defer for
		// now; but, leave a note that it might be worthwhile as a best practice.

	}

}
