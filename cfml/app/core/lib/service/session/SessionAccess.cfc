component {

	// Define properties for dependency-injection.
	property name="sessionModel" ioc:type="core.lib.model.session.SessionModel";
	property name="sessionValidation" ioc:type="core.lib.model.session.SessionValidation";
	property name="userModel" ioc:type="core.lib.model.user.UserModel";

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
		required numeric sessionID,
		string assertion = ""
		) {

		var userSession = sessionModel.get( sessionID );

		var context = {
			authContext,
			userSession,
			...getContextForParent( authContext, userSession.userID )
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

		return canViewAny( argumentCollection = arguments );

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

		sessionValidation.throwNotFoundError();

	}


	/**
	* I throw an access error.
	*/
	private void function throwForbiddenError() {

		sessionValidation.throwForbiddenError();

	}

}
