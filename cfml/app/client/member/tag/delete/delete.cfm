<cfscript>

	// Define properties for dependency-injection.
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	tagAccess = request.ioc.get( "core.lib.service.tag.TagAccess" );
	tagService = request.ioc.get( "core.lib.service.tag.TagService" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="url.tagID" type="numeric";
	param name="form.isConfirmed" type="boolean" default=false;

	partial = getPartial(
		authContext = request.authContext,
		tagID = val( url.tagID )
	);
	tag = partial.tag;

	title = "Delete Tag";
	errorResponse = "";

	request.response.title = title;

	if ( request.isPost ) {

		try {

			if ( ! form.isConfirmed ) {

				throw( type = "App.ConfirmationRequired" );

			}

			tagService.deleteTag(
				authContext = request.authContext,
				id = tag.id
			);

			router.goto([
				event: "member.tag.list",
				flash: "your.tag.deleted"
			]);

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	}

	include "./delete.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial(
		required struct authContext,
		required numeric tagID
		) {

		var context = tagAccess.getContext( authContext, tagID, "canDelete" );
		var tag = context.tag;

		return {
			tag
		};

	}

</cfscript>
