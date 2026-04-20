component {

	// Define properties for dependency-injection.
	property name="gateway" ioc:type="core.lib.model.system.task.TaskGateway";
	property name="validation" ioc:type="core.lib.model.system.task.TaskValidation";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I get a model.
	*/
	public struct function get(
		required string id,
		string withLock
		) {

		var results = getByFilter( argumentCollection = arguments );

		if ( ! results.len() ) {

			validation.throwNotFoundError();

		}

		return results.first();

	}


	/**
	* I get the model that match the given filters.
	*/
	public array function getByFilter(
		string id,
		date overdueAt,
		string withSort,
		string withLock
		) {

		return gateway.getByFilter( argumentCollection = arguments );

	}


	/**
	* I maybe get a model.
	*/
	public struct function maybeGet( required string id ) {

		return maybeGetByFilter( argumentCollection = arguments );

	}


	/**
	* I maybe get the first model that match the given filters.
	*/
	public struct function maybeGetByFilter(
		string id,
		date overdueAt
		) {

		return maybeArrayFirst( getByFilter( argumentCollection = arguments ) );

	}


	/**
	* I update a model.
	*
	* Caution: this method should be called inside a transaction block in which the target
	* row has obtained an exclusive lock. This ensures that the subsequent get() call used
	* to fill-in null values will lead to a consistent read.
	*/
	public void function update(
		required string id,
		struct state,
		date lastExecutedAt,
		date nextExecutedAt
		) {

		var existing = get( id );

		state = isNull( state )
			? existing.state
			: state
		;
		lastExecutedAt = isNull( lastExecutedAt )
			? existing.lastExecutedAt
			: lastExecutedAt
		;
		nextExecutedAt = isNull( nextExecutedAt )
			? existing.nextExecutedAt
			: nextExecutedAt
		;

		gateway.update(
			id = existing.id,
			state = state,
			lastExecutedAt = lastExecutedAt,
			nextExecutedAt = nextExecutedAt
		);

	}

}
