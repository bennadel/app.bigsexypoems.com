<cfoutput>

	<table bk7x3p #attributes.xClassToken# class="bk7x3p #attributes.xClass#">
	<cfloop array="#splitRows#" item="row">
		<tr>
			<td
				data-index="#e4a( row.left.index )#"
				data-type="#e4a( row.left.type )#"
				bk7x3p class="cell">

				<div class="tokens">
					<cfloop array="#row.left.tokens#" item="token">
						<em data-type="#e4a( token.type )#">#e( token.value )#<br /></em>
					</cfloop>
				</div>

			</td>
			<td
				data-index="#e4a( row.right.index )#"
				data-type="#e4a( row.right.type )#"
				bk7x3p class="cell">

				<div class="tokens">
					<cfloop array="#row.right.tokens#" item="token">
						<em data-type="#e4a( token.type )#">#e( token.value )#<br /></em>
					</cfloop>
				</div>

			</td>
		</tr>
	</cfloop>
	</table>

</cfoutput>
