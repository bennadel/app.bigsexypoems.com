<cfsavecontent variable="request.response.body">
<cfoutput>

	<div r2m8kt class="r2m8kt">

		<h1>
			#e( title )#
		</h1>

		<cfif entries.len()>

			<cfmodule
				template="/client/_shared/tag/errorMessage.cfm"
				response="#errorResponse#">
			</cfmodule>

			<form method="post" action="#request.postBackAction#" x-prevent-double-submit>
				<cfmodule template="/client/_shared/tag/xsrf.cfm" />

				<cfloop array="#entries#" item="entry" index="i">

					<details #ui.attrOpen( i == 1 )# r2m8kt class="disclosure">
						<summary r2m8kt class="summary">
							#e( entry.summary )#
						</summary>
						<section r2m8kt class="content">
							<cfset dump( entry.data ) />
						</section>
					</details>

				</cfloop>

				<div class="uiFormButtons">
					<button type="submit" name="deleteLogs" value="true" class="uiButton isDanger">
						Delete Logs
					</button>
				</div>
			</form>

		</cfif>

		<cfif ! entries.len()>

			<p>
				No logs &mdash; rock on with your bad self!
			</p>

		</cfif>

	</div>

</cfoutput>
</cfsavecontent>
