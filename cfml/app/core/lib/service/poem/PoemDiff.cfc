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

		var diff = myersDiff.diffElements(
			original = originalLines,
			modified = modifiedLines
		);

		// Interleave balanced mutation blocks so that each delete/insert pair sits
		// adjacent, then add word-level tokens for isolated single-line mutations. This
		// isn't perfect, but I think it aligns more closely with how poems are edited.
		interleaveOperations( diff.operations );
		tokenizeOperations( diff.operations );

		return diff.operations;

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

		var pattern = "\s+|[\w""'\-]+|\W+";

		return myersDiff.diffElements(
			original = original.reMatch( pattern ),
			modified = modified.reMatch( pattern ),
			caseSensitive = caseSensitive
		);

	}


	/**
	* I interleave balanced mutation blocks in the given operations array. Myers Diff
	* groups all deletes before all inserts (D1,D2,D3,I1,I2,I3). When a block has the
	* same number of deletes and inserts, we rearrange them so each delete is immediately
	* followed by its corresponding insert (D1,I1,D2,I2,D3,I3). This makes each pair an
	* isolated single-line mutation that the tokenizer can enhance with word-level detail.
	*/
	private void function interleaveOperations( required array operations ) {

		var i = 1;
		var operationCount = operations.len();

		while ( i <= operationCount ) {

			if ( operations[ i ].type == "equals" ) {

				i++;
				continue;

			}

			// We've hit a mutation - collect the entire contiguous block of delete and
			// insert operations.
			var blockStart = i;
			var deleteCount = 0;
			var insertCount = 0;

			while ( i <= operationCount ) {

				var current = operations[ i ];

				// Since Myers Diff always emits deletes before inserts within a given
				// change, we can only collect delete operations if we have no inserts. If
				// we see a delete after inserts, it must belong to a new block.
				if ( current.type == "delete" ) {

					// We've reached the end of the current block.
					if ( insertCount ) {

						break;

					}

					deleteCount++;
					i++;

				} else if ( current.type == "insert" ) {

					insertCount++;
					i++;

				} else {

					break;

				}

			}

			// For balanced blocks, interleave the deletes and inserts so that each
			// delete/insert pair sits adjacent in the array. This will create two-tuples
			// that represent isolated single-line changes.
			// --
			// Note: if the deleteCount is 1, we're already looking at an isolated line
			// mutation. As such, we only need to interleave for 2 or more lines.
			if (
				( deleteCount == insertCount ) &&
				( deleteCount >= 2 )
				) {

				var interleaved = [];

				// Zipper the interleaved collection in isolation.
				for ( var p = 0 ; p < deleteCount ; p++ ) {

					interleaved.append( operations[ blockStart + p ] );
					interleaved.append( operations[ blockStart + deleteCount + p ] );

				}

				// Override the original operation indices with the interleaved indices.
				for ( var p = 1 ; p <= interleaved.len() ; p++ ) {

					operations[ blockStart + p - 1 ] = interleaved[ p ];

				}

			}

		} // Outer while-loop.

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
		required array lineOperations,
		boolean caseSensitive = true
		) {

		lineOperations.each( ( lineOperation, i ) => {

			var tokens = lineOperation.tokens = [];

			// If the line operation is an equals or is part of a larger multi-line
			// mutation block, we can represent the entire line as a single token of the
			// overall line operation. This keeps a unified structure which makes the diff
			// easier to render.
			if ( ! isSingleLineMutation( lineOperations, i ) ) {

				tokens.append({
					type: lineOperation.type,
					value: lineOperation.value
				});
				return;

			}

			if ( lineOperation.type == "delete" ) {

				// Compare to next line (deletes are prioritized in diff order).
				var wordDiff = diffWords(
					original = lineOperation.value,
					modified = lineOperations[ i + 1 ].value,
					caseSensitive = caseSensitive
				);

			} else {

				// Compare to previous line (inserts are deprioritized in diff order).
				var wordDiff = diffWords(
					original = lineOperations[ i - 1 ].value,
					modified = lineOperation.value,
					caseSensitive = caseSensitive
				);

			}

			// Since we're rendering delete/insert lines next to each other, we only want
			// to include mutation tokens that match the overall line-operation.
			for ( var wordOperation in wordDiff.operations ) {

				if (
					( wordOperation.type == lineOperation.type ) ||
					( wordOperation.type == "equals" )
					) {

					tokens.append({
						type: wordOperation.type,
						value: wordOperation.value
					});

				}

			}

			// Collapse adjacent mutation tokens that are separated by a whitespace-only
			// equals token. This merges [mutation, whitespace, mutation] tuples into a
			// single token, which reads better for the user.
			var t = tokens.len();

			while ( t >= 3 ) {

				var minus0 = tokens[ t ];
				var minus1 = tokens[ t - 1 ];
				var minus2 = tokens[ t - 2 ];

				if (
					( minus0.type != "equals" ) &&
					( minus1.type == "equals" ) &&
					( minus0.type == minus2.type ) &&
					( minus1.value.trim() == "" )
					) {

					minus2.value &= "#minus1.value##minus0.value#";
					tokens.deleteAt( t-- );
					tokens.deleteAt( t-- );

				} else {

					t--;

				}

			}

			// Now that we've collapsed white-space-based tuples, let's further collapse
			// any sibling tokens that have the same type.
			var t = tokens.len();

			while ( t >= 2 ) {

				var minus0 = tokens[ t ];
				var minus1 = tokens[ t - 1 ];

				if ( minus0.type == minus1.type ) {

					minus1.value &= minus0.value;
					tokens.deleteAt( t-- );

				} else {

					t--;

				}

			}

		});

		return lineOperations;

	}

}
