component hint = "I help detect memory leaks in ColdFusion components." {

	// Define properties for dependency-injection.
	property name="ioc" ioc:type="core.lib.util.Injector";
	property name="logger" ioc:type="core.lib.util.Logger";
	property name="magicFunctionName" ioc:skip;
	property name="magicTokenName" ioc:skip;

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	/**
	* I initialize the memory leak detector.
	*/
	public void function $init() {

		variables.magicTokenName = "$$MemoryLeakDetector$$Version$$";
		variables.magicFunctionName = "$$MemoryLeakDetector$$Inspect$$";

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I scan the services in the Injector, looking for memory leaks.
	* 
	* Caution: This should only be run in the LOCAL DEVELOPMENT environment. It can end up
	* logging messages and stacktraces on every request. Plus, it accesses shared memory
	* space without any locking, which would be dangerous in a production environment.
	*/
	public void function inspect() {

		var version = createUuid();
		var queue = structValueArray( ioc.getAll() );

		// We're going to perform a breadth-first search of the components, starting with
		// the Injector services and then collecting any additional components we find
		// along the way.
		while ( queue.isDefined( 1 ) ) {

			var target = queue.shift();

			if ( ! isComponent( target ) ) {

				continue;

			}

			// If this target has already been inspected, skip it. However, since memory
			// leaks may develop over time based on the user's interaction, we need to
			// check the version number (of the current inspection). Only skip if we're
			// in the same inspection workflow and we're revisiting this component.
			// --
			// Note: In Adobe ColdFusion, CFC's don't have a .keyExists() member method.
			// As such, in this case, I have to use the built-in function.
			if ( structKeyExists( target, magicTokenName ) && ( target[ magicTokenName ] == version ) ) {

				continue;

			}

			// Make sure we don't come back to this target within the current inspection.
			target[ magicTokenName ] = version;

			var targetMetadata = getFlatMetadataIndex( target );
			var targetName = targetMetadata.name;
			var propertyIndex = targetMetadata.propertyIndex;
			var functionIndex = targetMetadata.functionIndex;
			var targetScope = getVariablesScope( target );

			for ( var key in targetScope ) {

				// Skip the public scope - memory leaks only show up in the private scope.
				if ( key == "this" ) {

					continue;

				}

				// Hack: we're including CFMLX (CFML extensions) in a number of components
				// and there's no simple way to allow-list them. As such, I'm going to see
				// if they are of type Function and that they also exist in THIS component
				// which is also including the CFMLX functions.
				if (
					isCustomFunction( targetScope[ key ] ) &&
					variables.keyExists( key ) &&
					isCustomFunction( variables[ key ] )
					) {

					continue;

				}

				// Skip hidden functions created by the CFThread tag.
				if ( key.reFindNoCase( "^_cffunccfthread" ) ) {

					continue;

				}

				// Treat top-level null values as suspicious.
				if ( ! targetScope.keyExists( key ) ) {

					logMessage( "Possible memory leak in [#targetName#]: [null]." );
					continue;

				}

				if (
					! propertyIndex.keyExists( key ) &&
					! functionIndex.keyExists( key )
					) {

					logMessage( "Possible memory leak in [#targetName#]: [#key#]." );

				}

				if ( propertyIndex.keyExists( key ) ) {

					if (
						propertyIndex[ key ].keyExists( "memoryLeakDetector:skip" ) ||
						propertyIndex[ key ].keyExists( "ioc:skip" )
						) {

						continue;

					}

				}

				// If the value is, itself, a component, add it to the queue for
				// subsequent inspection.
				if ( isComponent( targetScope[ key ] ) ) {

					queue.append( targetScope[ key ] );

				}

			}

		}

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I return the variables scope in the current execution context.
	*/
	private any function dangerouslyAccessVariablesInCurrentContext() {

		// Caution: This method has been injected into a targeted component and is being
		// executed in the context of that targeted component.
		return variables;

	}


	/**
	* I return an abbreviated, flattened version of the given component metadata.
	*/
	private struct function getFlatMetadataIndex( required any input ) {

		var rootMetadata = getMetadata( input );
		// In order to make the chain visiting easier, let's create a fake "root" that
		// uses the input as a "parent". This way, the first step in our do-while loop can
		// always be an ".extends" navigation.
		var target = {
			extends: rootMetadata
		};
		// Stylistic choice, I'm using ordered structs here so that the "more concrete"
		// entries will be higher-up in the final collections. And, the "more abstract"
		// entries will be lower-down in the final collections.
		var propertyIndex = [:];
		var functionIndex = [:];

		do {

			target = target.extends;

			for ( var entry in target.properties ) {

				// Since we're walking up the component chain from more concrete to more
				// abstract, only include properties that haven't already been defined at
				// a more concrete level.
				if ( ! propertyIndex.keyExists( entry.name ) ) {

					propertyIndex[ entry.name ] = entry;

				}

			}

			for ( var entry in target.functions ) {

				// Since we're walking up the component chain from more concrete to more
				// abstract, only include functions that haven't already been defined at
				// a more concrete level.
				if ( ! functionIndex.keyExists( entry.name ) ) {

					functionIndex[ entry.name ] = entry;

				}

			}

		} while ( target.keyExists( "extends" ) );

		return {
			name: rootMetadata.name,
			propertyIndex,
			functionIndex
		};

	}


	/**
	* I return the variables scope for the given target.
	*/
	private struct function getVariablesScope( required any target ) {

		// Inject the spy method so that we'll be able to pierce the private scope of the
		// target and observe the internal state. It doesn't matter if we inject this
		// multiple times, we're the only consumers.
		target[ magicFunctionName ] = variables.dangerouslyAccessVariablesInCurrentContext;

		return invoke( target, magicFunctionName );

	}


	/**
	* I log the given message to the standard out (console).
	*/
	private void function logMessage( required string message ) {

		logger.warning( message );
		systemOutput( message, true );

	}

}
