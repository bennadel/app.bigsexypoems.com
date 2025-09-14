<cfscript>

	// Define properties for dependency-injection.
	taskService = request.ioc.get( "core.lib.service.system.task.TaskService" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="form.taskID" type="string";
	param name="form.password" type="string";

	taskService.executeOverdueTask( form.taskID, form.password );
	title = request.response.title = "Execute Task";
	taskID = form.taskID;

	include "./one.view.cfm";

</cfscript>
