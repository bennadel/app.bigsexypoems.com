component {

	// Define properties for dependency-injection.
	property name="poemModel" ioc:type="core.lib.model.poem.PoemModel";
	property name="poemValidation" ioc:type="core.lib.model.poem.PoemValidation";
	property name="userModel" ioc:type="core.lib.model.user.UserModel";

	// ---
	// CONTEXT METHODS.
	// ---

	/**
	* I get the context chain for the given model. Optionally asserts a given action.
	*/
	public struct function getContext(
		required struct authContext,
		required numeric poemID,
		string assertion = ""
		) {

		var poem = poemModel.get( poemID );

		var context = {
			authContext,
			poem,
			...getContextForParent( authContext, poem.userID )
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
		required numeric userID,
		string assertion = ""
		) {

		var user = userModel.get( userID );

		var context = {
			authContext,
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

		poemValidation.throwNotFoundError();

	}


	/**
	* I throw an access error.
	*/
	private void function throwForbiddenError() {

		poemValidation.throwForbiddenError();

	}

}
