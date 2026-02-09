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
	* I diff two poem versions and return an array of split-row structs for a side-by-side
	* view of the changes. Each row has "left" and "right" keys containing an operation
	* struct with word-level tokens for paired mutation highlighting.
	*/
	public array function getSplitRows(
		required string originalName,
		required string originalContent,
		required string modifiedName,
		required string modifiedContent
		) {

		// Prepend title as first line so title changes appear in the diff naturally.
		var originalLines = poemService.splitLines( originalContent );
		originalLines.prepend( "==" );
		originalLines.prepend( originalName );

		var modifiedLines = poemService.splitLines( modifiedContent );
		modifiedLines.prepend( "==" );
		modifiedLines.prepend( modifiedName );

		var diff = myersDiff.diffElements(
			original = originalLines,
			modified = modifiedLines
		);

		// Build the side-by-side rows directly from the flat operations, pairing deletes
		// with inserts positionally within each mutation block. Then, enhance paired
		// mutations with word-level tokens for inline highlighting.
		return tokenizeSplitRows( buildSplitRows( diff.operations ) );

	}

	// ---
	// PRIVATE METHODS.
	// ---

	/**
	* I transform the flat diff operations array into an array of row structs for the
	* side-by-side (split) view. Each row has "left" and "right" keys containing an
	* operation struct. Contiguous mutation blocks are collected and deletes are zip-
	* paired positionally with inserts; any orphans are paired with an empty placeholder.
	*/
	private array function buildSplitRows( required array operations ) {

		var rows = [];
		var placeholder = {
			type: "empty",
			value: "",
			index: 0
		};
		var i = 1;
		var operationCount = operations.len();

		while ( i <= operationCount ) {

			var current = operations[ i ];

			if ( current.type == "equals" ) {

				rows.append({
					left: current,
					right: current
				});

				i++;
				continue;

			}

			// We've hit a mutation. Collect the entire contiguous block of mutations.
			// Since Myers Diff emits all deletes before all inserts within a block, we'll
			// gather them into separate lists and then zip-pair them positionally.
			var deletes = [];
			var inserts = [];

			while ( i <= operationCount ) {

				current = operations[ i ];

				if ( current.type == "equals" ) {

					break;

				} else if ( current.type == "delete" ) {

					deletes.append( current );

				} else {

					inserts.append( current );

				}

				i++;

			}

			// Zip-pair deletes with inserts by position. Any leftover operations on
			// either side become orphans paired with an empty sentinel.
			var deleteCount = deletes.len();
			var insertCount = inserts.len();
			var pairCount = max( deleteCount, insertCount );

			for ( var p = 1 ; p <= pairCount ; p++ ) {

				var left = ( deletes[ p ] ?: duplicate( placeholder ) );
				var right = ( inserts[ p ] ?: duplicate( placeholder ) );

				rows.append({ left, right });

			}

		}

		return rows;

	}


	/**
	* I extract and collapse word-level tokens from a word diff for one side of a paired
	* mutation. The lineType ("delete" or "insert") determines which mutation tokens to
	* keep — the other side's mutations are filtered out since each side of the split view
	* only shows its own changes.
	*/
	private array function buildTokens(
		required array wordOperations,
		required string lineType
		) {

		var tokens = [];

		// Since we're using the same set of operation to build both the left/right sides
		// of the comparison, we need to filter word operations for the appropriate side.
		// A delete line shows delete and equals tokens; an insert line shows insert and
		// equals tokens.
		for ( var wordOperation in wordOperations ) {

			if (
				( wordOperation.type == lineType ) ||
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

		// Now that we've collapsed whitespace-based tuples, further collapse any sibling
		// tokens that have the same type.
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

		return tokens;

	}


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
	* I enhance split rows with word-level tokens. For rows where a delete is paired with
	* an insert (a mutation pair), both sides get word-level diff tokens that highlight
	* the specific changes within the line. All other rows get a single token containing
	* the full line value.
	*/
	private array function tokenizeSplitRows(
		required array splitRows,
		boolean caseSensitive = true
		) {

		for ( var row in splitRows ) {

			// If this row pairs a delete with an insert, perform a word-level diff to
			// highlight the specific changes within the line.
			if (
				( row.left.type == "delete" ) &&
				( row.right.type == "insert" )
				) {

				var wordDiff = diffWords(
					original = row.left.value,
					modified = row.right.value,
					caseSensitive = caseSensitive
				);

				row.left.tokens = buildTokens( wordDiff.operations, "delete" );
				row.right.tokens = buildTokens( wordDiff.operations, "insert" );

			// For non-paired operations, represent the full line as a single token.
			} else {

				row.left.tokens = [{
					type: row.left.type,
					value: row.left.value
				}];
				row.right.tokens = [{
					type: row.right.type,
					value: row.right.value
				}];

			}

		}

		return splitRows;

	}

}
