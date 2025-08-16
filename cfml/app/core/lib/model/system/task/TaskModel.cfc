component {

	// Define properties for dependency-injection.
	property name="clock" ioc:type="core.lib.util.Clock";
	property name="gateway" ioc:type="core.lib.model.system.task.TaskGateway";
	property name="validation" ioc:type="core.lib.model.system.task.TaskValidation";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I get a model.
	*/
	public struct function get( required string id ) {

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
		date overdueAt
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

		var results = getByFilter( argumentCollection = arguments );

		if ( results.len() ) {

			return {
				exists: true,
				value: results.first()
			};

		}

		return {
			exists: false
		};

	}


	/**
	* I update a model.
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
