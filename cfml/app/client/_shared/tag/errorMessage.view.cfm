<cfoutput>

	<p
		x-data="pm14ud.ErrorMessage"
		tabindex="-1"
		role="alert"
		aria-live="assertive"
		pm14ud #attributes.xClassToken#
		class="error-message #attributes.xClass#">

		#e( message )#

		<!--- So that the top of the message doesn't butt-up against the viewport. --->
		<span
			aria-hidden="true"
			x-ref="scrollTarget"
			pm14ud
			class="scroll-margin">
		</span>
	</p>

</cfoutput>
