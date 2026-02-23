<cfoutput>

	<div aria-hidden="true" g8c588 class="g8c588">

		<div class="corner">
			<a href="#e4a( urlWithInit )#">
				<mark>Re-init</mark>
			</a>

			#e( slug )#

			<a href="/scribble/index.cfm" target="_blank">
				Scribble
			</a>

			<cfif logCount>
				<a #ui.attrHref( "dev.log" )# target="_blank" style="color: red ;">
					<strong>
						#numberFormat( logCount )# Logs
					</strong>
				</a>
			</cfif>
		</div>

		<cfif ! isSimpleValue( error )>

			<section class="error">

				<h2>
					Last Processed Error
				</h2>

				<!--- Note: I'm using my internal polyfill for better output control. --->
				<cfset dump( error ) />

			</section>

		</cfif>

	</div>

</cfoutput>
