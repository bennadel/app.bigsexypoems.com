<cfscript>

	// Prevents browsers from MIME-sniffing a response's content type. Without this,
	// browsers may interpret a file as a different type than what the Content-Type header
	// declares (e.g., executing a text file as HTML/JavaScript).
	cfheader(
		name = "X-Content-Type-Options",
		value = "nosniff"
	);

	// Prevents the site from being embedded in an iframe on another domain. This mitigates
	// clickjacking attacks where an attacker overlays invisible iframes to trick users into
	// clicking hidden buttons.
	cfheader(
		name = "X-Frame-Options",
		value = "DENY"
	);

	// Controls how much URL information is sent in the Referer header when navigating to
	// another site. This setting sends the full URL for same-origin requests, origin-only
	// for cross-origin requests, and nothing when downgrading from HTTPS to HTTP.
	cfheader(
		name = "Referrer-Policy",
		value = "strict-origin-when-cross-origin"
	);

</cfscript>
