<cfscript>

	// Define properties for dependency-injection.
	requestHelper = request.ioc.get( "core.lib.web.RequestHelper" );
	router = request.ioc.get( "core.lib.web.Router" );
	tagService = request.ioc.get( "core.lib.service.tag.TagService" );
	ui = request.ioc.get( "core.lib.web.UI" );

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ------------------------------------------------------------------------------- //
	// ------------------------------------------------------------------------------- //

	param name="form.name" type="string" default="";
	param name="form.slug" type="string" default="";

	title = "Create New Tag";
	errorResponse = "";

	request.response.title = title;

	if ( request.isPost ) {

		try {

			form.slug = form.slug.len()
				? form.slug
				: form.name.left( 20 ).lcase()
			;

			tagID = tagService.createTag(
				authContext = request.authContext,
				tagUserID = request.authContext.user.id,
				tagName = form.name,
				tagSlug = form.slug,
				// Todo: these will be user-driven in the future.
				tagFillHex = "ffffff",
				tagTextHex = "000000"
			);

			router.goto([
				event: "member.tag.list",
				flash: "your.tag.created"
			]);

		} catch ( any error ) {

			errorResponse = requestHelper.processError( error );

		}

	}

	include "./add.view.cfm";

</cfscript>
