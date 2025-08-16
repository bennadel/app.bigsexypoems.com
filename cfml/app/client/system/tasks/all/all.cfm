<cfscript>

	taskService = request.ioc.get( "core.lib.service.system.task.TaskService" );

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	taskCount = taskService.executeOverdueTasks();
	title = request.response.title = "Execute All Tasks";

	include "./all.view.cfm";

</cfscript>
