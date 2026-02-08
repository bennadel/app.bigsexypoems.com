component {

	// Define properties for dependency-injection.
	property name="myersDiff" ioc:type="core.lib.util.MyersDiff";
	property name="poemService" ioc:type="core.lib.service.poem.PoemService";

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I diff two poem versions and return line-level operations with word-level tokens for
	* isolated single-line mutation highlighting.
	*/
	public array function getDiffOperations(
		required string originalName,
		required string originalContent,
		required string modifiedName,
		required string modifiedContent
		) {

		// Prepend title as first line so title changes appear in the diff naturally.
		var originalLines = poemService.splitLines( originalContent );
		originalLines.prepend( "---" );
		originalLines.prepend( originalName );

		var modifiedLines = poemService.splitLines( modifiedContent );
		modifiedLines.prepend( "---" );
		modifiedLines.prepend( modifiedName );

		var lineDiff = myersDiff.diffElements(
			original = originalLines,
			modified = modifiedLines
		);

		// Add word-level tokens for single-line mutations.
		return tokenizeOperations( lineDiff.operations );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I perform a word-level diff against the two strings. Words and whitespace runs are
	* treated as separate tokens, preserving spacing in the output.
	*/
	private struct function diffWords(
		required string original,
		required string modified,
		boolean caseSensitive = true
		) {

		return myersDiff.diffElements(
			original = original.reMatch( "\s+|\w+|\W+" ),
			modified = modified.reMatch( "\s+|\w+|\W+" ),
			caseSensitive = caseSensitive
		);

	}


	/**
	* I determine if the given operation is an isolated mutation (ie, not part of a larger
	* block of mutations). Single line mutations allow us to be more detailed in the line
	* rendering, showing sub-token replacements.
	*/
	private boolean function isSingleLineMutation(
		required array operations,
		required numeric operationIndex
		) {

		var noop = { type: "equals" };
		var minus2 = ( operations[ operationIndex - 2 ] ?: noop );
		var minus1 = ( operations[ operationIndex - 1 ] ?: noop );
		var operation = operations[ operationIndex ];
		var plus1 = ( operations[ operationIndex + 1 ] ?: noop );
		var plus2 = ( operations[ operationIndex + 2 ] ?: noop );

		if ( operation.type == "equals" ) {

			return false;

		}

		if (
			( operation.type == minus1.type ) ||
			( operation.type == plus1.type )
			) {

			return false;

		}

		if (
			( minus1.type != "equals" ) &&
			( minus1.type == minus2.type )
			) {

			return false;

		}

		if (
			( plus1.type != "equals" ) &&
			( plus1.type == plus2.type )
			) {

			return false;

		}

		return true;

	}


	/**
	* I enhance element-level diff operations with word-level tokens. For "single line
	* mutations" (a single delete immediately followed by a single insert, where neither
	* operation is part of a consecutive series), the tokens array contains word-level
	* diff results. For all other operations, the tokens array contains a single token
	* with the full value.
	*/
	private array function tokenizeOperations(
		required array operations,
		boolean caseSensitive = true
		) {

		operations.each(
			( operation, i ) => {

				var tokens = operation.tokens = [];

				if ( ! isSingleLineMutation( operations, i ) ) {

					tokens.append({
						type: operation.type,
						value: operation.value
					});
					return;

				}

				if ( operation.type == "delete" ) {

					// Compare to next line (deletes are prioritized in diff order).
					var wordDiff = diffWords(
						original = operation.value,
						modified = operations[ i + 1 ].value,
						caseSensitive = caseSensitive
					);

				} else {

					// Compare to previous line (inserts are deprioritized in diff order).
					var wordDiff = diffWords(
						original = operations[ i - 1 ].value,
						modified = operation.value,
						caseSensitive = caseSensitive
					);

				}

				// Since we're rendering delete/insert lines next to each other, we only
				// want to include mutation tokes that match the overall line-operation.
				for ( var wordOperation in wordDiff.operations ) {

					if (
						( wordOperation.type == operation.type ) ||
						( wordOperation.type == "equals" )
						) {

						tokens.append({
							type: wordOperation.type,
							value: wordOperation.value
						});

					}

				}

				// Now that we've accumulated the tokens for the current operation, let's
				// collapse adjacent mutation tokens that are separated by a whitespace-
				// only equals token. This merges [mutation, whitespace, mutation] tuples
				// into a single token, which reads better for the user.
				var t = tokens.len();

				while ( t >= 3 ) {

					if (
						( tokens[ t ].type == tokens[ t - 2 ].type ) &&
						( tokens[ t ].type != "equals" ) &&
						( tokens[ t - 1 ].type == "equals" ) &&
						( tokens[ t - 1 ].value.trim() == "" )
						) {

						tokens[ t - 2 ].value &= "#tokens[ t - 1 ].value##tokens[ t ].value#";
						tokens.deleteAt( t-- );
						tokens.deleteAt( t-- );

					} else {

						t--;

					}

				}

			}
		);

		return operations;

	}

}
