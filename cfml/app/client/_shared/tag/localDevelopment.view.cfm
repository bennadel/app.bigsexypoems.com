<cfoutput>

	<div g8c588>

		<div class="corner">
			<a href="#e4a( urlWithInit )#">
				<mark>Re-init</mark>
			</a>

			#e( slug )#

			<a href="/internal/scribble/scribble.cfm" target="_blank">
				Scribble
			</a>
		</div>

		<cfif ! isSimpleValue( error )>

			<section class="error">

				<h2>
					Last Processed Error
				</h2>

				<cfdump
					var="#error#"
					hide="Element, ErrNumber, Id, ObjectType, Raw_Trace, ResolvedName, Stacktrace, Suppressed"
				/>

			</section>

		</cfif>

	</div>

</cfoutput>
