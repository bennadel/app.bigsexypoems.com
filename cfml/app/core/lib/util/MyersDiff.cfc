component hint="I provide a ColdFusion implementation of the Myers Diffing algorithm." {

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	/**
	* I initialize the differ.
	*/
	public void function init() {
		// ... no state needed at this time ...
	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I perform a diff against the two strings.
	*/
	public struct function diff(
		required string original,
		required string modified,
		boolean caseSensitive = true
		) {

		return diffElements(
			original = original.reMatch( "." ),
			modified = modified.reMatch( "." ),
			caseSensitive = caseSensitive
		);

	}


	/**
	* I perform a diff against the two arrays of strings.
	*/
	public struct function diffElements(
		required array original,
		required array modified,
		boolean caseSensitive = true
		) {

		// To make the elements easier to work with (so that row/col indices align with
		// input indices), we're going to create local copies of the input arrays with a
		// front-loaded throw-away string. The diffing algorithm works by creating a
		// matrix of "steps" to get from the original string to the modified string; and
		// the whole situation is way easier if we can treat location (1,1) as a UNIQUE
		// value before the start of each string. This keeps all the indices simple!
		var paddedOriginal = [ createUuid(), ...original ];
		var paddedModified = [ createUuid(), ...modified ];

		// In our matrix, the original text is represented horizontally (by columns) and
		// our modified text is represented vertically (by rows).
		var matrix = matrixNew(
			rowCount = paddedModified.len(),
			columnCount = paddedOriginal.len()
		);

		// Flesh-out the "steps" that we MIGHT take to get from original to modified.
		matrix.each( ( row, rowIndex ) => {
			row.each( ( entry, columnIndex ) => {

				// PERFORMANCE TRADE-OFF: I'm storing a lot more data in each entry that
				// is actually needed because the stored data makes the algorithm easier
				// to think about. But, it also means the algorithm is slower and needs
				// more memory.
				entry.originalValue = paddedOriginal[ columnIndex ];
				entry.modifiedValue = paddedModified[ rowIndex ];
				// Adjust indices to account for the empty string at (1,1).
				entry.originalIndex = ( columnIndex - 1 );
				entry.modifiedIndex = ( rowIndex - 1 );
				// Flag when original and modified content match at the given offsets.
				entry.match = valuesAreEqual( entry.originalValue, entry.modifiedValue, caseSensitive );
				// Store the steps it took to get to the sibling locations of the matrix.
				// We'll use this in both the path identification and the back-tracing to
				// find optimal operations.
				entry.north = ( matrix[ rowIndex - 1 ][ columnIndex ].steps ?: 0 );
				entry.northWest = ( matrix[ rowIndex - 1 ][ columnIndex - 1 ].steps ?: 0 );
				entry.west = ( matrix[ rowIndex ][ columnIndex - 1 ].steps ?: 0 );

				// First row is based solely on index. As we move RIGHT across the matrix,
				// every step indicates a single "deletion" of the original text.
				if ( rowIndex == 1 ) {

					entry.steps = ( columnIndex - 1 );

				// First column is based solely on index. As we move DOWN across the
				// matrix, every step indicates a single "insertion" of the modified text.
				} else if ( columnIndex == 1 ) {

					entry.steps = ( rowIndex - 1 );

				// If the original / modified texts match at current location, we don't
				// have to increase the "steps" since only modifications count as a step.
				// As such, we'll copy the steps it took to get to the previous location.
				} else if ( entry.match ) {

					entry.steps = entry.northWest;

				// If the original / modified texts differ at the current location, add a
				// step to the smallest non-matching path it took to get to the siblings.
				} else {

					entry.steps = ( min( entry.north, entry.west ) + 1 );

				}

			});
		});

		// Now that we've populated the matrix with various step-paths, we're going to
		// start at the end of the matrix and back-trace through the steps to find the
		// smallest number of operations that get us from the original text to the
		// modified text (with an emphasis on "delete" operations - meaning we want the
		// final operations to list deletes before inserts wherever possible).
		var columnIndex = paddedOriginal.len();
		var rowIndex = paddedModified.len();
		var operations = [];
		var counts = {
			equals: 0,
			insert: 0,
			delete: 0,
			total: 0
		};

		while ( true ) {

			// The origin (1,1) is just the throw-away placeholder that we added to make
			// all the sibling math easier (no null-reference errors). If we've traced
			// back to the placeholder, we can exit the tracing.
			if ( ( rowIndex == 1 ) && ( columnIndex == 1 ) ) {

				break;

			}

			var entry = matrix[ rowIndex ][ columnIndex ];

			// Determine which operations represent viable paths.
			var canUseMatch = entry.match;
			var canUseInsert = (
				( rowIndex > 1 ) &&
				( entry.steps == ( entry.north + 1 ) )
			);
			var canUseDelete = (
				( columnIndex > 1 ) &&
				( entry.steps == ( entry.west + 1 ) )
			);

			// Note: since we're BACK TRACING from the end of the matrix and PREPENDING
			// steps, the operation priority is reversed from the following checks. By
			// checking for INSERTIONS before DELETIONS, it means that DELETIONS will
			// actually occur first when the operations are played-back in the correct
			// order (due to the prepending of entries).
			if ( canUseMatch ) {

				operations.prepend({
					type: "equals",
					value: entry.originalValue,
					index: entry.originalIndex
				});
				counts.equals++;
				counts.total++;

				// Move diagonally for matches.
				columnIndex--;
				rowIndex--;

			} else if ( canUseInsert ) {

				operations.prepend({
					type: "insert",
					value: entry.modifiedValue,
					index: entry.modifiedIndex
				});
				counts.insert++;
				counts.total++;

				// Move vertically for insertions.
				rowIndex--;

			} else if ( canUseDelete ) {

				operations.prepend({
					type: "delete",
					value: entry.originalValue,
					index: entry.originalIndex
				});
				counts.delete++;
				counts.total++;

				// Move horizontally for deletions.
				columnIndex--;

			}

		}

		return [
			operations: operations,
			counts: counts
		];

	}


	/**
	* I perform a word-level diff against the two strings. Words and whitespace runs are
	* treated as separate tokens, preserving spacing in the output.
	*/
	public struct function diffWords(
		required string original,
		required string modified,
		boolean caseSensitive = true
		) {

		return diffElements(
			original = original.reMatch( "\s+|\w+|\W+" ),
			modified = modified.reMatch( "\s+|\w+|\W+" ),
			caseSensitive = caseSensitive
		);

	}


	/**
	* I enhance element-level diff operations with word-level tokens. For "single line
	* mutations" (a single delete immediately followed by a single insert, where neither
	* operation is part of a consecutive series), the tokens array contains word-level
	* diff results. For all other operations, the tokens array contains a single token
	* with the full value.
	*/
	public array function tokenizeOperations(
		required array operations,
		boolean caseSensitive = true
		) {

		operations.each(
			( operation, i ) => {

				operation.tokens = [];

				if ( ! isSingleLineMutation( operations, i ) ) {

					operation.tokens.append({
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

				wordDiff.operations.each(
					( wordOperation, ii, wordOperations ) => {

						// If the type applies to a different line-level operation, omit
						// it - the token will be rendered by a different line.
						if (
							( wordOperation.type != operation.type ) &&
							( wordOperation.type != "equals" )
							) {

							return;

						}

						operation.tokens.append({
							type: wordOperation.type,
							value: wordOperation.value
						});

						// If a white-space token is surrounded by two mutation tokens of
						// the same type, let's collapsed the three tokens down to one.
						// This reads better for the user.
						if ( operation.tokens.len() >= 3 ) {

							var minus2 = operation.tokens[ operation.tokens.len() - 2 ];
							var minus1 = operation.tokens[ operation.tokens.len() - 1 ];
							var minus0 = operation.tokens[ operation.tokens.len() ];

							if (
								( minus0.type == wordOperation.type ) &&
								( minus0.type == minus2.type ) &&
								( minus1.type == "equals" ) &&
								( minus1.value.trim() == "" )
								) {

								minus2.value &= "#minus1.value##minus0.value#";
								operation.tokens.pop();
								operation.tokens.pop();

							}

						}

					}
				);

			}
		);

		return operations;

	}

	// ---
	// PRIVATE METHODS.
	// ---

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
	* I create a matrix with the given dimensions.
	*/
	private array function matrixNew(
		required numeric rowCount,
		required numeric columnCount
		) {

		var row = [];
		row.resize( columnCount );

		for ( var i = 1 ; i <= columnCount ; i++ ) {

			row[ i ] = {};

		}

		var matrix = [];
		matrix.resize( rowCount );

		for ( var i = 1 ; i <= rowCount ; i++ ) {

			matrix[ i ] = duplicate( row );

		}

		return matrix;

	}


	/**
	* I determine if the two values are equal. The compare() functions return 0 when
	* the values match, which makes for confusing code. This method wraps the comparison
	* and returns a boolean that reads more naturally.
	*/
	private boolean function valuesAreEqual(
		required string valueA,
		required string valueB,
		required boolean caseSensitive
		) {

		if ( caseSensitive ) {

			return ! compare( valueA, valueB );

		} else {

			return ! compareNoCase( valueA, valueB );

		}

	}

}
