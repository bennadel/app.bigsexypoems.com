component
	output = false
	hint = "I provide utility methods around date/time access."
	{

	/**
	* I return the number of milliseconds since January 1, 1970, 00:00:00 GMT represented
	* by this given date/time value.
	*/
	public numeric function dateGetTime( required any input ) {

		if ( isInstanceOf( input, "java.util.Date" ) ) {

			return input.getTime();

		}

		return dateAdd( "d", 0, input ).getTime();
	}


	/**
	* I return the current date/time in UTC.
	*/
	public date function utcNow() {

		return dateConvert( "local2utc", now() );

	}

}
