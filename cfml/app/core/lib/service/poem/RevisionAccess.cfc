component {

	// Define properties for dependency-injection.
	property name="poemModel" ioc:type="core.lib.model.poem.PoemModel";
	property name="revisionModel" ioc:type="core.lib.model.poem.RevisionModel";
	property name="revisionValidation" ioc:type="core.lib.model.poem.RevisionValidation";
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
		required numeric revisionID,
		string assertion = ""
		) {

		var revision = revisionModel.get( revisionID );

		var context = {
			authContext,
			revision,
			...getContextForParent( authContext, revision.poemID )
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
	public boolean function canDelete(
		required struct authContext,
		required struct user
		) {

		return canView( argumentCollection = arguments );

	}


	/**
	* I determine if the action can be performed.
	*/
	public boolean function canMakeCurrent(
		required struct authContext,
		required struct user
		) {

		return canView( argumentCollection = arguments );

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

		revisionValidation.throwNotFoundError();

	}


	/**
	* I throw an access error.
	*/
	private void function throwForbiddenError() {

		revisionValidation.throwForbiddenError();

	}

}
