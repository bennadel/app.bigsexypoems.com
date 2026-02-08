<cfoutput>

	<div vf9k2m #attributes.xClassToken# class="vf9k2m #attributes.xClass#">
		<cfloop array="#diffOperations#" item="operation">

			<span data-index="#e4a( operation.index )#" data-type="#e4a( operation.type )#" vf9k2m class="line">
				<cfloop array="#operation.tokens#" item="token">
					<em data-type="#e4a( token.type )#">#e( token.value )#<br /></em>
				</cfloop>
			</span>

		</cfloop>
	</div>

</cfoutput>
