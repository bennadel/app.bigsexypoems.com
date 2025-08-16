
<!--- Import custom tag libraries. --->
<cfimport prefix="core" taglib="../dsl/core/" />

<!--- // ------------------------------------------------------------------------- // --->
<!--- // ------------------------------------------------------------------------- // --->

<cfoutput>

	<cfset theme = getBaseTagData( "cf_email" ).theme />
	<!---
		In order to keep things as simple as possible, I've decided to go with the Roboto
		font for both Title text and Copy text. This will also keep the experience more
		consistent on GMail, which doesn't support font loading but DOES INCLUDE the
		Roboto font for its own email designs (which means we can use it there as well).
	--->
	<cfset theme.importUrls.append( "https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" ) />

	<!--- Configure light theme. --->
	<cfset theme.light.primary = "##4682b4" />
	<cfset theme.light.secondary = "##4682b4" />
	<cfset theme.light.background = "##fefefe" />
	<cfset theme.light.surface = "##fefefe" />
	<cfset theme.light.error = "##b00020" />
	<cfset theme.light.onPrimary = "##ffffff" />
	<cfset theme.light.onSecondary = "##ffffff" />
	<cfset theme.light.onBackground = "##22252b" />
	<cfset theme.light.onSurface = "##22252b" />
	<cfset theme.light.onError = "##ffffff" />

	<!--- Configure dark theme. --->
	<cfset theme.dark.primary = "##3f51b5" />
	<cfset theme.dark.secondary = "##4682b4" />
	<cfset theme.dark.background = "##121212" />
	<cfset theme.dark.surface = "##121212" />
	<cfset theme.dark.error = "##cf6679" />
	<cfset theme.dark.onPrimary = "##000000" />
	<cfset theme.dark.onSecondary = "##000000" />
	<cfset theme.dark.onBackground = "##ffffff" />
	<cfset theme.dark.onSurface = "##ffffff" />
	<cfset theme.dark.onError = "##000000" />

	<!--- Configure the block-element margins. --->
	<!---
	<core:Provide name="margins.blockquote" value="" />
	<core:Provide name="margins.h1" value="" />
	<core:Provide name="margins.h2" value="" />
	<core:Provide name="margins.h3" value="" />
	<core:Provide name="margins.h4" value="" />
	<core:Provide name="margins.h5" value="" />
	<core:Provide name="margins.hr" value="" />
	<core:Provide name="margins.ol" value="" />
	<core:Provide name="margins.p" value="" />
	<core:Provide name="margins.pre" value="" />
	<core:Provide name="margins.table" value="" />
	<core:Provide name="margins.ul" value="" />
	--->

	<!---
		First, setup the basic font properties. These are limited to color, font-size,
		font-family, and line-height.
	--->
	<core:HtmlEntityTheme entity="h1, h2, h3, h4, h5, th">
		color: #theme.light.onSurface# ;
		font-family: Roboto, BlinkMacSystemFont, helvetica, arial, sans-serif ;
		font-weight: 700 ;
	</core:HtmlEntityTheme>
	<core:HtmlEntityTheme entity="h1">
		font-size: 23px ;
		line-height: 33px ;
	</core:HtmlEntityTheme>
	<core:HtmlEntityTheme entity="h2">
		font-size: 22px ;
		line-height: 32px ;
	</core:HtmlEntityTheme>
	<!---
	<core:HtmlEntityTheme entity="h3">
		font-size: 20px ;
		line-height: 28px ;
	</core:HtmlEntityTheme>
	<core:HtmlEntityTheme entity="h4, h5, th">
		font-size: 16px ;
		line-height: 24px ;
	</core:HtmlEntityTheme>
	--->
	<!--- IMG being included for the ALT text if the image doesn't load. --->
	<core:HtmlEntityTheme entity="blockquote, img, li, p, td">
		color: #theme.light.onSurface# ;
		font-family: Roboto, BlinkMacSystemFont, helvetica, arial, sans-serif ;
		font-size: 16px ;
		font-weight: 400 ;
		line-height: 23px ;
	</core:HtmlEntityTheme>
	<core:HtmlEntityTheme entity="a">
		color: #theme.light.primary# ;
	</core:HtmlEntityTheme>
	<core:HtmlEntityTheme entity="a" class="email">
		font-weight: 400 ;
	</core:HtmlEntityTheme>

	<!---
		When it comes to "bold" fonts, we have to be careful about email clients that
		don't support external web fonts. In some clients, any font-weight below 600 will
		show up as a "normal" weight. And, any font-weight at or above 600 will show up
		as a "bold" weight. As such, we have to use font-weights that will fall-back in a
		way that leads to a better user experience.
	--->
	<core:HtmlEntityTheme entity="span" class="semi-bold">
		font-weight: 500 ; <!--- Will fallback to "normal" on some clients. --->
	</core:HtmlEntityTheme>
	<core:HtmlEntityTheme entity="strong">
		font-weight: 700 ;
	</core:HtmlEntityTheme>

	<!--- Special overrides where we want the look to diverge from the semantics. --->
	<core:HtmlEntityTheme entity="h1, h2, h3, h4, h5, th" class="copy-size">
		font-size: 16px ;
		line-height: 24px ;
	</core:HtmlEntityTheme>
	<core:HtmlEntityTheme entity="h1, h2, h3, h4, h5, span, th" class="copy-weight">
		font-weight: 400 ;
	</core:HtmlEntityTheme>
	<core:HtmlEntityTheme entity="a" class="copy-color">
		color: #theme.light.onSurface# ;
	</core:HtmlEntityTheme>

	<!--- Setup reponsive styles. --->
	<!---
	<core:MaxWidthStyles width="414">
		.html-entity-h1.responsive {
			font-size: 24px ;
			line-height: 32px ;
		}

		.html-entity-h2.responsive {
			font-size: 21px ;
			line-height: 29px ;
		}

		.html-entity-h3.responsive {
			font-size: 18px ;
			line-height: 26px ;
		}
	</core:MaxWidthStyles>
	--->

	<core:HtmlEntityTheme entity="a" class="title">
		color: #theme.light.onSurface# ;
		display: block ;
	</core:HtmlEntityTheme>
	<core:HeaderStyles>
		a.title:hover {
			text-decoration: underline ;
		}
	</core:HeaderStyles>

	<core:HtmlEntityTheme entity="p" class="centered">
		text-align: center ;
	</core:HtmlEntityTheme>

	<!--- Setup core dark-mode styles - only works in a few clients. --->
	<core:DarkModeStyles>
		.html-entity-h1,
		.html-entity-h2,
		.html-entity-h3,
		.html-entity-h4,
		.html-entity-h5,
		.html-entity-th,
		.html-entity-blockquote,
		.html-entity-img,
		.html-entity-li,
		.html-entity-p,
		.html-entity-td,
		.html-entity-a.title,
		.html-entity-a.copy-color {
			color: #theme.dark.onSurface# ;
		}

		.html-entity-blockquote {
			border-left-color: ##767676 ;
		}
	</core:DarkModeStyles>

	<!---
		Since MSO / Outlook clients won't load remote fonts, we have to define a
		solid fallback font family and weight.
	--->
	<core:HeaderContent>
		<core:IfMso>
			<style type="text/css">
				h1, h2, h3, h4, h5, th {
					font-family: helvetica, arial, sans-serif !important ;
					font-weight: 700 !important ;
				}
				blockquote, body, img, li, p, td, .copy-font {
					font-family: helvetica, arial, sans-serif !important ;
					font-weight: 400 ;
				}
				strong {
					font-weight: 700 !important ;
				}
			</style>
		</core:IfMso>
	</core:HeaderContent>

</cfoutput>
