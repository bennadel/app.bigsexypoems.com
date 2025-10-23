component
	extends = "core.lib.model.BaseValidation"
	{

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	// ---
	// VALIDATION METHODS.
	// ---

	/**
	* I validate and return the normalized value.
	*/
	public string function fillHexFrom( required string input ) {

		return pipeline(
			normalizeString( input ).lcase(),
			[
				assertHexColor: [ "App.Model.Tag.FillHex.Invalid" ]
			]
		);

	}


	/**
	* I validate and return the normalized value.
	*/
	public string function nameFrom( required string input ) {

		return pipeline(
			normalizeString( input ),
			[
				assertNotEmpty: [ "App.Model.Tag.Name.Empty" ],
				assertMaxLength: [ 50, "App.Model.Tag.Name.TooLong" ],
				assertUniformEncoding: [ "App.Model.Tag.Name.SuspiciousEncoding" ]
			]
		);

	}


	/**
	* I validate and return the normalized value.
	*/
	public string function slugFrom( required string input ) {

		return pipeline(
			normalizeString( input ),
			[
				assertNotEmpty: [ "App.Model.Tag.Slug.Empty" ],
				assertMaxLength: [ 20, "App.Model.Tag.Slug.TooLong" ],
				assertUniformEncoding: [ "App.Model.Tag.Slug.SuspiciousEncoding" ]
			]
		);

	}


	/**
	* I validate and return the normalized value.
	*/
	public string function textHexFrom( required string input ) {

		return pipeline(
			normalizeString( input ).lcase(),
			[
				assertHexColor: [ "App.Model.Tag.TextHex.Invalid" ]
			]
		);

	}

	// ---
	// ERROR METHODS.
	// ---

	/**
	* I throw a model error.
	*/
	public void function throwForbiddenError() {

		throw( type = "App.Model.Tag.Forbidden" );

	}


	/**
	* I throw a model error.
	*/
	public void function throwNotFoundError() {

		throw( type = "App.Model.Tag.NotFound" );

	}

}
