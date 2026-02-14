component
	hint = "I provide utility methods around date/time access and formatting."
	{

	// ColdFusion language extensions (global functions).
	include "/core/cfmlx.cfm";

	/**
	* I initialize the clock.
	*/
	public void function init() {

		// Note: I've decided to put all of these constants in the public scope since they
		// might be helpful elsewhere. But, they could have just as easily been put in the
		// private scope and locked-down to consumption within this component.
		this.MS_SECOND = 1000;
		this.MS_MINUTE = ( this.MS_SECOND * 60 );
		this.MS_HOUR = ( this.MS_MINUTE * 60 );
		this.MS_DAY = ( this.MS_HOUR * 24 );
		this.MS_MONTH = ( this.MS_DAY * 30 ); // Rough estimate.
		this.MS_YEAR = ( this.MS_DAY * 365 ); // Rough estimate.

		// The Moment.js library documents the "buckets" into which the "FROM NOW" deltas
		// fall. To mimic this logic using milliseconds since epoch, let's calculate rough
		// estimates of all the offsets. Then, we simply need to find the lowest matching
		// bucket for a given date.
		// --
		// Read more: https://momentjs.com/docs/#/displaying/fromnow/
		this.FROM_NOW_JUST_NOW = ( this.MS_SECOND * 44 );
		this.FROM_NOW_MINUTE = ( this.MS_SECOND * 89 );
		this.FROM_NOW_MINUTES = ( this.MS_MINUTE * 44 );
		this.FROM_NOW_HOUR = ( this.MS_MINUTE * 89 );
		this.FROM_NOW_HOURS = ( this.MS_HOUR * 21 );
		this.FROM_NOW_DAY = ( this.MS_HOUR * 35 );
		this.FROM_NOW_DAYS = ( this.MS_DAY * 25 );
		this.FROM_NOW_MONTH = ( this.MS_DAY * 45 );
		this.FROM_NOW_MONTHS = ( this.MS_DAY * 319 );
		this.FROM_NOW_YEAR = ( this.MS_DAY * 547 );

	}

	// ---
	// PUBLIC METHODS.
	// ---

	/**
	* I format the given date relative to now - all dates are assumed to be in UTC.
	*/
	public string function fromNow( required date input ) {

		var nowTick = dateGetTime( utcNow() );
		var inputTick = dateGetTime( input );
		var delta = ( nowTick - inputTick );
		var prefix = "";
		var infix = "";
		var suffix = " ago"; // Assume past-dates by default.

		// If we're dealing with a future date, we need to flip the delta so that our
		// buckets can be used in a consistent manner. We will compensate for this change
		// by using a different prefix/suffix.
		if ( delta < 0 ) {

			delta = abs( delta );
			prefix = "in ";
			suffix = "";

		}

		// Note: We are using ceiling() in the following calculations so that we never
		// round-down to a "singular" number that may clash with a plural identifier (ex,
		// "days"). All singular numbers are handled by explicit delta-buckets.
		if ( delta <= this.FROM_NOW_JUST_NOW ) {

			infix = "a few seconds";

		} else if ( delta <= this.FROM_NOW_MINUTE ) {

			infix = "a minute";

		} else if ( delta <= this.FROM_NOW_MINUTES ) {

			infix = ( ceiling( delta / this.MS_MINUTE ) & " minutes" );

		} else if ( delta <= this.FROM_NOW_HOUR ) {

			infix = "an hour";

		} else if ( delta <= this.FROM_NOW_HOURS ) {

			infix = ( ceiling( delta / this.MS_HOUR ) & " hours" );

		} else if ( delta <= this.FROM_NOW_DAY ) {

			infix = "a day";

		} else if ( delta <= this.FROM_NOW_DAYS ) {

			infix = ( ceiling( delta / this.MS_DAY ) & " days" );

		} else if ( delta <= this.FROM_NOW_MONTH ) {

			infix = "a month";

		} else if ( delta <= this.FROM_NOW_MONTHS ) {

			infix = ( ceiling( delta / this.MS_MONTH ) & " months" );

		} else if ( delta <= this.FROM_NOW_YEAR ) {

			infix = "a year";

		} else {

			infix = ( ceiling( delta / this.MS_YEAR ) & " years" );

		}

		return ( prefix & infix & suffix );
	}

}
