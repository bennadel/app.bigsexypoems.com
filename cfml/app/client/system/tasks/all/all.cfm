<cfscript>

	taskService = request.ioc.get( "core.lib.service.system.task.TaskService" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	taskCount = taskService.executeOverdueTasks();
	title = request.response.title = "Execute All Tasks";

	include "./all.view.cfm";

</cfscript>
