
import { readFile } from "node:fs/promises";
import { Reporter } from "@parcel/plugin";
import { writeFile } from "node:fs/promises";

// ----------------------------------------------------------------------------------- //
// ----------------------------------------------------------------------------------- //

/**
* I strip the <html>+<body> wrapper that Parcel adds to the generated `.html` files when
* running in development / watch mode. The wrapper was causing the browser to move the
* link and script tags to the body of the resultant DOM tree. This now allows the output
* of the build to be the same in production and development mode.
*/
export default new Reporter({
	async report({ event, logger }) {

		if ( event.type !== "buildSuccess" ) {

			return;

		}

		var bundleGraph = event.bundleGraph;
		var bundles = bundleGraph.getBundles();

		for ( var bundle of bundles ) {

			if ( bundle.type !== "html" ) {

				continue;

			}

			var filePath = bundle.filePath;
			var content = await readFile( filePath, "utf8" );
			var stripped = content
				.replace( "<html><head>", "" )
				.replace( "</head><body></body></html>", "" )
				.trim()
			;

			if ( stripped !== content ) {

				await writeFile( filePath, stripped, "utf8" );
				// Output the stripped file to the docker output. This is for my own
				// benefit as a developer, so that I don't forget this is happening.
				logger.info({
					message: filePath
				});

			}

		}

	}
});
