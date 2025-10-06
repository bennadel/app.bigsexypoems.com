<!---
	When the browser submits the form in response to the keyboard (ex, user hits "Enter"
	while focused on a text field), the browser searches the DOM, looking for the first
	submit button in DOM-order. The problem is, if the first submit button is a named
	submit - that is, it has a [name="value"] attribute - the browser will use this button
	as the submit operation; and, will include the [name="value"] form parameter. This is
	probably not what the user expected.

	By including a [hidden] submit button at the top of the form, we ensure that the
	browser will always use this _unnamed_ submit button for keyboard-based submissions.
--->
<button
	type="submit"
	hidden="I am used to submit the form in response to keyboard-based operations.">
</button>
