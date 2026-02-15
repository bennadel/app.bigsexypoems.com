<cfsavecontent variable="request.response.body">
<cfoutput>

	<article qv3x8n class="qv3x8n">

		<h1>
			#e( title )#
		</h1>

		<nav aria-labelledby="#ui.nextFieldId()#" class="uiPageNav">
			<span id="#ui.fieldId()#">
				Revision Actions:
			</span>
			<ul>
				<cfif isRevisionStale>
					<li>
						<a #ui.attrHref( "member.poem.revision.makeCurrent", "revisionID", revision.id )#>Make Current</a>
					</li>
				</cfif>
				<li>
					<a #ui.attrHref( "member.poem.revision.delete", "revisionID", revision.id )#>Delete</a>
				</li>
			</ul>
		</nav>

		<div qv3x8n class="revisionMeta">
			<h2 qv3x8n class="revisionDate">
				#ui.userDateTime( revision.createdAt )#
				<span class="uiSubtext">
					#ui.fromNow( revision.createdAt )#
				</span>
			</h2>
			<nav qv3x8n class="revisionNav">
				<cfif maybeOlder.exists>
					<a #ui.attrHref( "member.poem.revision.view", "revisionID", maybeOlder.value.id )#>&larr; Older</a>
				<cfelse>
					<span qv3x8n class="isDisabled">&larr; Older</span>
				</cfif>
				<cfif maybeNewer.exists>
					<a #ui.attrHref( "member.poem.revision.view", "revisionID", maybeNewer.value.id )#>Newer &rarr;</a>
				<cfelse>
					<span qv3x8n class="isDisabled">Newer &rarr;</span>
				</cfif>
			</nav>
		</div>

		<cfmodule
			template="/client/member/_shared/tag/poemDiff.cfm"
			originalHeader="Revision"
			originalName="#revision.name#"
			originalContent="#revision.content#"
			modifiedHeader="Live Poem"
			modifiedName="#poem.name#"
			modifiedContent="#poem.content#">
		</cfmodule>

	</article>

</cfoutput>
</cfsavecontent>
