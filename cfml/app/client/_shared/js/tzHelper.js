
window.TzOffsetController = function() {

	// The native timezone offset gives us the number of minutes that we'd have to add to
	// the LOCAL time in order to get the UTC time. However, we're going to use this on
	// the server, where we're already in UTC time. As such, in order to make the date
	// maths easier, we want to store the INVERSE OFFSET such that we can calculate the
	// LOCAL time from the UTC time.
	this.$el.value = -( new Date().getTimezoneOffset() );

};
