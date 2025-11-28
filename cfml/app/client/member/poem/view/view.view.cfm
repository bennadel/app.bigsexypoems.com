<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			#e( poem.name )#
		</h1>

		<cfif maybeCollection.exists>
			<p>
				<strong>Collection:</strong>
				<a #ui.attrHref( "member.collection.view", "collectionID", maybeCollection.value.id )#>#e( maybeCollection.value.name )#</a>
			</p>
		</cfif>

		<nav aria-labelledby="#ui.nextFieldId()#" class="uiPageNav">
			<span id="#ui.fieldId()#">
				Poem Actions:
			</span>
			<ul>
				<li>
					<a #ui.attrHref( "member.poem.composer", "poemID", poem.id )#>Composer</a>
				</li>
				<li>
					<a #ui.attrHref( "member.poem.edit", "poemID", poem.id )#>Edit</a>
				</li>
				<li>
					<a #ui.attrHref( "member.poem.delete", "poemID", poem.id )#>Delete</a>
				</li>
				<li>
					<a #ui.attrHref( "member.poem.share", "poemID", poem.id )#>Share Links</a>
				</li>
			</ul>
		</nav>

		<ul vyxlrv class="lines">
			<cfloop array="#lines#" item="line">
				<li>
					#e( line )#<br />
				</li>
			</cfloop>
		</ul>

	</article>

</cfoutput>
</cfsavecontent>
