
<div
	x-data="jy2g1b.Toaster"
	@app:toast.document="handleToast( $event )"
	jy2g1b :class="{
		jy2g1b: true,
		isActive: items.length
	}">

	<!---
		Note: since toasts are messages that are shown to the user without a page refresh,
		they will always be assertive, whether or not they are errors. To use non-
		assertive alerts, a full page refresh needs to be performed with a flash message.
	--->
	<template x-for="( item, i ) in items" :key="item.uid">

		<div
			role="alert"
			aria-live="assertive"
			aria-atomic="true"
			:class="{
				item: true,
				isError: item.isError
			}">
			<div class="message" x-text="item.message">
				<!--- Populated by Alpine. --->
			</div>
			<button @click="removeItem( i )" tabindex="0" class="uiButton isText dismiss">
				Dismiss
			</button>
		</div>

	</template>

</div>
