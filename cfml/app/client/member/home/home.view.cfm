<cfsavecontent variable="request.response.body">
<cfoutput>

	<article class="uiFlow">

		<h1>
			Home
		</h1>

		<p>
			Welcome, #encodeForHtml( user.name )# &lt;#encodeForHtml( user.email )#&gt;
		</p>

		<p>
			<strong>BigSexy</strong>:
			<em>( /biɡ &##712;seks&##275;/ ) noun</em>.
			&mdash;
			Your muse. Your inspiration. The part of your soul that feels deeply, lives with abandon, and loves without limits.
		</p>

	</article>

</cfoutput>
</cfsavecontent>
