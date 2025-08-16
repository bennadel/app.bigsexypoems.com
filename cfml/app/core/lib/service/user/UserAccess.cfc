component {

	// Define properties for dependency-injection.
	property name="userModel" ioc:type="core.lib.model.user.UserModel";
	property name="userValidation" ioc:type="core.lib.model.user.UserValidation";

	// ---
	// CONTEXT METHODS.
	// ---

	/**
	* I get the context chain for the given model. Optionally asserts a given action.
	*/
	public struct function getContext(
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
	public struct function getContextForParent() {

		throw( type = "App.NoParentContext" );

	}

	// ---
	// ASSERTION METHODS.
	// ---

	/**
	* I determine if the update action can be performed.
	*/
	public boolean function canUpdate(
		required struct authContext,
		required struct user
		) {

		if ( ! authContext.session.isAuthenticated ) {

			return false;

		}

		return ( authContext.user.id == user.id );

	}


	/**
	* I determine if the view action can be performed.
	*/
	public boolean function canView(
		required struct authContext,
		required struct user
		) {

		if ( ! authContext.session.isAuthenticated ) {

			return false;

		}

		return ( authContext.user.id == user.id );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I throw a not found access error.
	*/
	private void function throwNotFoundError() {

		userValidation.throwNotFoundError();

	}


	/**
	* I throw a forbidden access error.
	*/
	private void function throwForbiddenError() {

		userValidation.throwForbiddenError();

	}

}
