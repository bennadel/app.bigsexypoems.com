<cfoutput>

	<p
		x-data="izm317.FlashMessage"
		tabindex="-1"
		role="alert"
		aria-live="polite"
		izm317 #e4a( attributes.xClassToken )#
		class="izm317 #e4a( attributes.xClass )#">

		#e( flashResponse.message )#

		<cfif flashResponse.link.exists>
			<a href="#e4a( flashResponse.link.href )#">#e( flashResponse.link.text )#</a>
		</cfif>
	</p>

</cfoutput>
