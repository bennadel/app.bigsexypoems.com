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
	param name="form.name" type="string" default="";
	param name="form.slug" type="string" default="";

	partial = getPartial(
		authContext = request.authContext,
		tagID = val( url.tagID )
	);
	tag = partial.tag;
	title = "Update Tag";
	errorResponse = "";

	request.response.title = title;

	if ( request.isGet ) {

		form.name = tag.name;
		form.slug = tag.slug;

	}

	if ( request.isPost ) {

		try {

			form.slug = form.slug.len()
				? form.slug
				: form.name.left( 20 ).lcase()
			;

			tagID = tagService.updateTag(
				authContext = request.authContext,
				tagID = tag.id,
				tagName = form.name,
				tagSlug = form.slug
			);

			router.goto([
				event: "member.tag.list",
				flash: "your.tag.updated"
			]);

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	}

	include "./edit.view.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	/**
	* I get the partial data for the view.
	*/
	private struct function getPartial(
		required struct authContext,
		required numeric tagID
		) {

		var context = tagAccess.getContext( authContext, tagID, "canUpdate" );
		var tag = context.tag;

		return {
			tag
		};

	}

</cfscript>
