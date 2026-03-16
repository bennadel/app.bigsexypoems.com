---
paths:
  - "**/*.view.cfm"
  - "**/*.view.less"
  - "**/*.view.js"
---

# View Templates (.view.cfm / .view.less / .view.js)

A view may optionally include `.view.less` (Less CSS) and/or `.view.js` (Alpine.js) alongside the `.cfm` / `.view.cfm` pair.

## Slug Scoping

Since the asset build system has no automatic scoping, we simulate it with a random 6-character lowercase alphanumeric slug that **MUST** begin with a letter (e.g., `mq9evq`). This slug is used as an HTML attribute, CSS attribute selector, class name, and JavaScript global variable — all sharing the same value.

## CSS Scoping in `.view.less`

All CSS rules are nested under an attribute selector using the slug. Two patterns target elements:

- **Direct match (`&.className`)** — element has both the slug attribute AND the class. Compiles to `[slug].className`.
- **Descendant match (`.className`)** — element is a descendant of a slug-attributed ancestor. Compiles to `[slug] .className`.

```less
[mq9evq] {
	&.mq9evq {
		// Root element: compiles to [mq9evq].mq9evq
	}

	&.title {
		// Direct match: compiles to [mq9evq].title
	}

	.item {
		// Descendant: compiles to [mq9evq] .item
	}
}
```

```cfml
<div mq9evq class="mq9evq">
	<h2 mq9evq class="title">
		Direct-matched element (has slug attribute)
	</h2>
	<div class="item">
		Descendant-matched element (no slug attribute needed)
	</div>
</div>
```

Both patterns can be mixed. The root element typically uses `&.slug` for its own styles. Define CSS keyframe animations outside the `[slug]` block, prefixed with the slug:

```less
@keyframes mq9evq-enter-blink {
	// animations specific to this view.
}
```

**CSS custom properties over hardcoded colors**: Never hardcode hex colors in Less files. Use the design system's CSS variables (e.g., `var( --error-fill )`, `var( --success-text )`).

## Alpine.js Components in `.view.js`

If a `.view.js` file exists, it defines one or more Alpine.js components using the slug as a global namespace. Components use a revealing module pattern with section comments matching the `.cfc` convention:

```js
window.mq9evq = {
	MyComponent,
};

function MyComponent() {

	return {
		// Life-Cycle Methods.
		init,

		// Public Methods.
		doSomething,
	};

	// ---
	// LIFE-CYCLE METHODS.
	// ---

	/**
	* I initialize the component.
	*/
	function init() {

		// ...

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I do something.
	*/
	function doSomething() {

		// ...

	}

}
```

Components are bound in `.view.cfm` via `x-data` attributes: `<div x-data="mq9evq.MyComponent">`.

## Form Field Patterns

When creating form fields in `.view.cfm` templates:

- Use `<label for="#ui.nextFieldId()#" class="uiField_label">` (not `<span>`) for field labels
- Add `id="#ui.fieldId()#"` to the corresponding input element
- Use `ui.attrChecked()` helper for checkbox/radio checked state instead of inline `<cfif>` conditionals
- Use `ui.attrSelected()` helper for select option selected state
- Add the `x-keyed-focus` directive to the first visible form element within a form so it receives focus on page load

Example checkbox field:

```cfm
<div class="uiField">
	<label for="#ui.nextFieldId()#" class="uiField_label">
		Field Label:
	</label>
	<div class="uiField_content">
		<label class="uiHstack">
			<input
				id="#ui.fieldId()#"
				type="checkbox"
				name="fieldName"
				value="true"
				#ui.attrChecked( form.fieldName )#
				class="uiCheckbox"
			/>
			<span>Checkbox description</span>
		</label>
	</div>
</div>
```

## Associating JavaScript / Less CSS Files With Templates

Each major subsystem has a root `.js` entry point (e.g., `/client/member/member.js`) that auto-discovers all `.view.js` and `.view.less` files within its directory tree via a glob import:

```js
import "./**/*.view.{js,less}";
```

This means adding a new view with `.view.js` or `.view.less` files requires no manual import — they are automatically included in the next build.

The root entry point also explicitly imports shared modules from `_shared/tag/` (which are outside the subsystem directory and can't be auto-discovered):

```js
import "../_shared/tag/errorMessage.view.{js,less}";
import "../_shared/tag/toaster.view.{js,less}";
```

When creating a new shared tag in `_shared/tag/`, you must add an explicit import for it in each root entry point that uses it.
