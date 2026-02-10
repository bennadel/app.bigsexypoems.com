<cfoutput>

	<table bk7x3p #attributes.xClassToken# class="bk7x3p #attributes.xClass#">
	<cfif ( originalHeader.len() || modifiedHeader.len() )>
		<thead>
			<tr>
				<th bk7x3p class="header">
					#e( originalHeader )#
				</th>
				<th bk7x3p class="header">
					#e( modifiedHeader )#
				</th>
			</tr>
		</thead>
	</cfif>
	<cfloop array="#splitRows#" item="row">
		<tr>
			<td
				data-type="#e4a( row.left.type )#"
				bk7x3p class="cell">

				<div bk7x3p class="tokens">
					<cfloop array="#row.left.tokens#" item="token">
						<em
							data-type="#e4a( token.type )#"
							bk7x3p class="token"
							>#e( token.value )#<br /></em>
					</cfloop>
				</div>

			</td>
			<td
				data-type="#e4a( row.right.type )#"
				bk7x3p class="cell">

				<div bk7x3p class="tokens">
					<cfloop array="#row.right.tokens#" item="token">
						<em
							data-type="#e4a( token.type )#"
							bk7x3p class="token"
							>#e( token.value )#<br /></em>
					</cfloop>
				</div>

			</td>
		</tr>
	</cfloop>
	</table>

</cfoutput>
