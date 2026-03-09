<cfoutput>

	<p
		x-data="pm14ud.ErrorMessage"
		tabindex="-1"
		role="alert"
		aria-live="assertive"
		aria-atomic="true"
		pm14ud #e4a( attributes.xClassToken )#
		class="pm14ud #e4a( attributes.xClass )#">

		#e( message )#

		<!--- So that the top of the message doesn't butt-up against the viewport. --->
		<span
			aria-hidden="true"
			x-ref="scrollTarget"
			pm14ud class="scrollMargin">
		</span>
	</p>

</cfoutput>
