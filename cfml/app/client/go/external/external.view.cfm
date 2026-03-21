<cfsavecontent variable="request.response.body">
<cfoutput>

	<section om9qys class="om9qys uiReadableWidth">

		<h1 class="title">
			You Are Leaving #e( sitename )#
		</h1>

		<p class="message">
			You are being redirected to an external website &mdash;
			<mark>#e( externalHostname )#</mark> &mdash;
			this link was shared by a user and is not controlled by #e( sitename )#.
			You should only click on links that you trust.
		</p>

		<div class="url">
			<label for="#ui.nextFieldId()#" class="url_label">
				External URL:
			</label>
			<div class="uiHstack">
				<input
					id="#ui.fieldId()#"
					type="text"
					readonly
					value="#e4a( externalUrl )#"
					class="uiInput"
					@focus="$el.select()"
				/>
				<a
					href="#e4a( externalUrl )#"
					rel="noopener noreferrer"
					class="uiButton isDanger isNoWrap">
					Continue &rarr;
				</a>
			</div>
		</div>

		<p>
			No thanks, <a href="/">take me back to #e( sitename )#</a>.
		</p>

	</section>

</cfoutput>
</cfsavecontent>
