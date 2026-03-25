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

	// Isolates the browsing context so that cross-origin documents opened via pop-ups or
	// window.open() cannot access this page's window object (and vice versa). This
	// prevents cross-origin attacks that exploit the window.opener reference.
	cfheader(
		name = "Cross-Origin-Opener-Policy",
		value = "same-origin"
	);

	// Prevents other origins from loading this site's resources (images, scripts, styles,
	// etc.) via cross-origin requests. This mitigates side-channel attacks like Spectre
	// that can leak data from cross-origin resources loaded into an attacker's process.
	cfheader(
		name = "Cross-Origin-Resource-Policy",
		value = "same-origin"
	);

</cfscript>
