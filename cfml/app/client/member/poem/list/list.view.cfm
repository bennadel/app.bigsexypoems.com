<cfsavecontent variable="request.response.body">
<cfoutput>

	<article>

		<h1>
			#e( title )#
		</h1>

		<p>
			<a #ui.attrHref( "member.poem.add" )#>Add Poem</a>
			|
			<a #ui.attrHref( "member.poem.global.share.list" )#>All Share Links</a>
		</p>

		<cfif recentPoems.len()>

			<h2>
				Recently Updated Poems
			</h2>

			<cfmodule
				template="./poemTable.cfm"
				poems="#recentPoems#"
			/>

		</cfif>

		<cfif poems.len()>

			<!--- We only need the title if we have to differentiate two sections. --->
			<cfif recentPoems.len()>
				<h2>
					All Poems
				</h2>
			</cfif>

			<cfmodule
				template="./poemTable.cfm"
				poems="#poems#"
			/>

		</cfif>

		<cfif ! poems.len()>

			<p>
				You have no poems yet. <a #ui.attrHref( "member.poem.add" )#>Write your first poem</a>.
			</p>

		</cfif>

	</article>

</cfoutput>
</cfsavecontent>
