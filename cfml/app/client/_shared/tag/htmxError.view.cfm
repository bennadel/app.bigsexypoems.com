
<div
	x-data="jy2g1b.HtxmError"
	@htmx:before-swap.document="handleResponse( $event )"
	jy2g1b
	:class="{
		jy2g1b: true,
		isActive: isActive
	}"
	role="alert"
	aria-live="assertive"
	aria-atomic="true">

	<div jy2g1b class="tile">
		<div x-ref="errorContent">
			<!--- Populated dynamically. --->
		</div>
		<button @click="close()">
			close
		</button>
	</div>

</div>
