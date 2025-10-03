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
	public string function ipAddressFrom( required string input ) {

		return pipeline(
			normalizeString( input ).lcase(),
			[
				assertNotEmpty: [ "App.Model.Poem.Share.Viewing.IpAddress.Empty" ],
				assertMaxLength: [ 45, "App.Model.Poem.Share.Viewing.IpAddress.TooLong" ],
				assertIpAddress: [ "App.Model.Poem.Share.Viewing.IpAddress.Invalid" ]
			]
		);

	}


	/**
	* I validate and return the normalized value.
	*/
	public string function ipCityFrom( required string input ) {

		return pipeline(
			normalizeString( input ),
			[
				assertMaxLength: [ 50, "App.Model.Poem.Share.Viewing.IpCity.TooLong" ]
			]
		);

	}


	/**
	* I validate and return the normalized value.
	*/
	public string function ipCountryFrom( required string input ) {

		return pipeline(
			normalizeString( input ).ucase(),
			[
				assertMaxLength: [ 2, "App.Model.Poem.Share.Viewing.IpCountry.TooLong" ]
			]
		);

	}


	/**
	* I validate and return the normalized value.
	*/
	public string function ipRegionFrom( required string input ) {

		return pipeline(
			normalizeString( input ),
			[
				assertMaxLength: [ 50, "App.Model.Poem.Share.Viewing.IpRegion.TooLong" ]
			]
		);

	}

	// ---
	// ERROR METHODS.
	// ---

	/**
	* I throw a not-found error.
	*/
	public void function throwNotFoundError() {

		throw( type = "App.Model.Poem.Share.Viewing.NotFound" );

	}

}
