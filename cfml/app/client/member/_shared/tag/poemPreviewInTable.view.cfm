<cfoutput>

	<div cggnns #xClassToken# class="container #xClass#">
		<!--- All devices can "see" the static, truncated version (with no opacity). --->
		<span cggnns class="static">
			#e( truncate( content, maxLength ) )#
		</span>

		<!---
			The dynamic, expansive version is hidden from assistive technology so as not
			overwhelm the user with long content.
		--->
		<span aria-hidden="true" cggnns class="dynamic">
			#e( content )#
		</span>
	</div>

</cfoutput>
