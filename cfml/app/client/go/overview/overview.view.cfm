<cfsavecontent variable="request.response.body">
<cfoutput>

	<section p14ook class="p14ook uiReadableWidth">

		<h1>
			#e( title )#
		</h1>

		<p>
			This is a directory of short-links to other features within
			<a href="/">#e( config.site.name )#</a>.
		</p>

		<ul>
			<cfloop array="#links#" item="link">
				<li>
					<a href="/go/#e( link.stub )#"><mark><strong>#e( link.stub )#</strong></mark></a>:
					#e( link.description )#
				</li>
			</cfloop>
		</ul>

	</section>

</cfoutput>
</cfsavecontent>
