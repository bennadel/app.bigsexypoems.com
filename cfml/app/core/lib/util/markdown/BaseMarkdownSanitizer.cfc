component hint = "I provide utility methods for all markdown sanitizers." {

	/**
	* I return the report of unsafe markup that will be removed from the given DOM once
	* the given safelist is applied.
	*/
	public struct function getUnsafeMarkup(
		required any safelist,
		required any dom
		) {

		var unsafe = {
			tags: [],
			attributes: []
		};

		// The internal Cleaner algorithm uses a NodeVisitor pattern since it's doing more
		// complicated construction. But, we can do roughly get the same access to the DOM
		// by simply grabbing all the elements in the body.
		for ( var element in dom.body().getAllElements() ) {

			var tagName = element.normalName();

			// We're starting at the body element because that's what the .body() method
			// gives us. But the body won't be part of the content that we're actually
			// validating - it's just the natural container of the parsed content.
			if ( tagName == "body" ) {

				continue;

			}

			// Validate the tag name against the Safelist.
			if ( ! safelist.isSafeTag( tagName ) ) {

				unsafe.tags.append([
					type: "tag",
					tagName: tagName
				]);

				// If we're dropping this whole element, there's no need to also examine
				// its attributes.
				continue;

			}

			// Validate the attributes against the Safelist.
			for ( var attribute in element.attributes().asList() ) {

				if ( ! safelist.isSafeAttribute( tagName, element, attribute ) ) {

					unsafe.attributes.append([
						type: "attribute",
						tagName: tagName,
						attributeName: attribute.getKey(),
						attributeValue: attribute.getValue()
					]);

				}

			}

		}

		return unsafe;

	}

}
