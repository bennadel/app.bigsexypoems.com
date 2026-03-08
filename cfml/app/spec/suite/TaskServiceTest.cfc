component extends="spec.BaseTest" {

	// Define properties for dependency-injection.
	property name="scheduledTasks" ioc:get="config.scheduledTasks";
	property name="taskModel" ioc:type="core.lib.model.system.task.TaskModel";
	property name="taskService" ioc:type="core.lib.service.system.task.TaskService";

	// ---
	// HAPPY PATH TESTS.
	// ---

	/**
	* I test that executeOverdueTask executes a task handler, updates lastExecutedAt and
	* nextExecutedAt, and persists the new state.
	*/
	public void function testExecuteOverdueTask() {

		var tasks = taskModel.getByFilter();
		var task = tasks.first();

		// Make the task overdue so it will execute.
		taskModel.update(
			id = task.id,
			nextExecutedAt = utcNow().add( "n", -5 )
		);

		var beforeTask = taskModel.get( task.id );

		taskService.executeOverdueTask(
			taskID = task.id,
			password = scheduledTasks.password
		);

		var afterTask = taskModel.get( task.id );

		// Verify timestamps were updated.
		assertTrue(
			( afterTask.lastExecutedAt > beforeTask.lastExecutedAt ),
			"Expected lastExecutedAt to be updated."
		);
		assertTrue(
			( afterTask.nextExecutedAt > utcNow() ),
			"Expected nextExecutedAt to be in the future."
		);

	}


	/**
	* I test that executeOverdueTask skips execution when the task's nextExecutedAt is
	* in the future (too early), leaving timestamps unchanged.
	*/
	public void function testExecuteOverdueTaskTooEarly() {

		var tasks = taskModel.getByFilter();
		var task = tasks.first();

		// Set nextExecutedAt far in the future.
		var futureDate = utcNow().add( "d", 30 );
		taskModel.update(
			id = task.id,
			nextExecutedAt = futureDate
		);

		var beforeTask = taskModel.get( task.id );

		taskService.executeOverdueTask(
			taskID = task.id,
			password = scheduledTasks.password
		);

		var afterTask = taskModel.get( task.id );

		// Verify timestamps were NOT updated (task was skipped).
		assertEqual( afterTask.lastExecutedAt, beforeTask.lastExecutedAt );
		assertEqual( afterTask.nextExecutedAt, beforeTask.nextExecutedAt );

	}

	// ---
	// SAD PATH TESTS.
	// ---

	/**
	* I test that executeOverdueTask throws when given an incorrect password.
	*/
	public void function testExecuteOverdueTaskWithIncorrectPassword() {

		var tasks = taskModel.getByFilter();
		var task = tasks.first();

		assertThrows(
			() => {

				taskService.executeOverdueTask(
					taskID = task.id,
					password = "wrong-password-#createUUID()#"
				);

			},
			"App.ScheduledTasks.IncorrectPassword"
		);

	}


	/**
	* I test that executeOverdueTask throws when given an invalid task ID.
	*/
	public void function testExecuteOverdueTaskWithInvalidTaskID() {

		assertThrows(
			() => {

				taskService.executeOverdueTask(
					taskID = "nonexistent-task-#createUUID()#",
					password = scheduledTasks.password
				);

			},
			"App.Model.System.Task.NotFound"
		);

	}

}
