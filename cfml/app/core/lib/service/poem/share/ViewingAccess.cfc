component {

	// Define properties for dependency-injection.
	property name="poemModel" ioc:type="core.lib.model.poem.PoemModel";
	property name="shareModel" ioc:type="core.lib.model.poem.share.ShareModel";
	property name="userModel" ioc:type="core.lib.model.user.UserModel";
	property name="viewingModel" ioc:type="core.lib.model.poem.share.ViewingModel";
	property name="viewingValidation" ioc:type="core.lib.model.poem.share.ViewingValidation";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// CONTEXT METHODS.
	// ---

	/**
	* I get the context chain for the given model. Optionally asserts a given action.
	*/
	public struct function getContext(
		required struct authContext,
		required numeric viewingID,
		string assertion = ""
		) {

		var viewing = viewingModel.get( viewingID );

		var context = {
			authContext,
			viewing,
			...getContextForParent( authContext, viewing.shareID )
		};

		if ( assertion.len() ) {

			if ( ! invoke( this, "canView", context ) ) {

				throwNotFoundError();

			}

			if ( ! invoke( this, assertion, context ) ) {

				throwForbiddenError();

			}

		}

		return context;

	}


	/**
	* I get the context chain for the given parent. Optionally asserts a given action.
	*/
	public struct function getContextForParent(
		required struct authContext,
		required numeric shareID,
		string assertion = ""
		) {

		var share = shareModel.get( shareID );
		var poem = poemModel.get( share.poemID );
		var user = userModel.get( poem.userID );

		var context = {
			authContext,
			share,
			poem,
			user
		};

		if ( assertion.len() ) {

			if ( ! invoke( this, assertion, context ) ) {

				throwForbiddenError();

			}

		}

		return context;

	}

	// ---
	// ASSERTION METHODS.
	// ---

	/**
	* I determine if the action can be performed.
	*/
	public boolean function canDelete(
		required struct authContext,
		required struct user
		) {

		return canView( argumentCollection = arguments );

	}


	/**
	* I determine if the action can be performed.
	*/
	public boolean function canDeleteAny(
		required struct authContext,
		required struct user
		) {

		return canViewAny( argumentCollection = arguments );

	}


	/**
	* I determine if the action can be performed.
	*/
	public boolean function canView(
		required struct authContext,
		required struct user
		) {

		if ( ! canViewAny( argumentCollection = arguments ) ) {

			return false;

		}

		return ( user.id == authContext.user.id );

	}


	/**
	* I determine if the action can be performed.
	*/
	public boolean function canViewAny(
		required struct authContext,
		required struct user
		) {

		if ( ! authContext.session.isAuthenticated ) {

			return false;

		}

		return ( user.id == authContext.user.id );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I throw an access error.
	*/
	private void function throwForbiddenError() {

		viewingValidation.throwForbiddenError();

	}


	/**
	* I throw an access error.
	*/
	private void function throwNotFoundError() {

		viewingValidation.throwNotFoundError();

	}

}
