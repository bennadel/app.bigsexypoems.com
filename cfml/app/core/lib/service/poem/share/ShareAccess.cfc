component {

	// Define properties for dependency-injection.
	property name="poemModel" ioc:type="core.lib.model.poem.PoemModel";
	property name="shareModel" ioc:type="core.lib.model.poem.share.ShareModel";
	property name="shareValidation" ioc:type="core.lib.model.poem.share.ShareValidation";
	property name="userModel" ioc:type="core.lib.model.user.UserModel";

	// ---
	// CONTEXT METHODS.
	// ---

	/**
	* I get the context chain for the given model. Optionally asserts a given action.
	*/
	public struct function getContext(
		required struct authContext,
		required numeric shareID,
		string assertion = ""
		) {

		var share = shareModel.get( shareID );

		var context = {
			authContext,
			share,
			...getContextForParent( authContext, share.poemID )
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
		required numeric poemID,
		string assertion = ""
		) {

		var poem = poemModel.get( poemID );
		var user = userModel.get( poem.userID );

		var context = {
			authContext,
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
	public boolean function canCreateAny(
		required struct authContext,
		required struct user
		) {

		return canViewAny( argumentCollection = arguments );

	}


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
	public boolean function canUpdate(
		required struct authContext,
		required struct user
		) {

		return canView( argumentCollection = arguments );

	}


	/**
	* I determine if the action can be performed.
	*/
	public boolean function canUpdateAny(
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
	private void function throwNotFoundError() {

		shareValidation.throwNotFoundError();

	}


	/**
	* I throw an access error.
	*/
	private void function throwForbiddenError() {

		shareValidation.throwForbiddenError();

	}

}
