<cfcomponent extends="core.lib.model.BaseGateway">

	<cffunction name="init" returnType="void">

		<cfset super.init(
			indexPrefixes = [
				"token",
			]
		) />

	</cffunction>

	<!--- PUBLIC METHODS. --->

	<cffunction name="create" returnType="void">

		<cfargument name="token" type="string" required="true" />
		<cfargument name="syllableCount" type="numeric" required="true" />
		<cfargument name="partsPerMillion" type="numeric" required="true" />
		<cfargument name="isAdjective" type="boolean" required="true" />
		<cfargument name="isAdverb" type="boolean" required="true" />
		<cfargument name="isNoun" type="boolean" required="true" />
		<cfargument name="isVerb" type="boolean" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			INSERT IGNORE INTO
				word
			SET
				token = <cfqueryparam value="#token#" cfsqltype="cf_sql_varchar" />,
				syllableCount = <cfqueryparam value="#syllableCount#" cfsqltype="cf_sql_tinyint" />,
				partsPerMillion = <cfqueryparam value="#partsPerMillion#" scale="6" cfsqltype="cf_sql_decimal" />,
				isAdjective = <cfqueryparam value="#isAdjective#" cfsqltype="cf_sql_tinyint" />,
				isAdverb = <cfqueryparam value="#isAdverb#" cfsqltype="cf_sql_tinyint" />,
				isNoun = <cfqueryparam value="#isNoun#" cfsqltype="cf_sql_tinyint" />,
				isVerb = <cfqueryparam value="#isVerb#" cfsqltype="cf_sql_tinyint" />
		</cfquery>

	</cffunction>


	<cffunction name="deleteByFilter" returnType="void">

		<cfargument name="token" type="string" required="false" />

		<cfset assertIndexPrefix( arguments ) />

		<cfquery name="local.results" result="local.metaResults">
			DELETE FROM
				word
			WHERE
				TRUE

			<cfif ! isNull( word )>
				AND
					word = <cfqueryparam value="#word#" cfsqltype="cf_sql_varchar" />
			</cfif>
		</cfquery>

	</cffunction>


	<cffunction name="getByFilter" returnType="array">

		<cfargument name="token" type="string" required="false" />
		<cfargument name="withSort" type="string" required="false" default="token" />

		<cfset assertIndexPrefix( arguments ) />

		<cfquery name="local.results" result="local.metaResults" returnType="array">
			SELECT
				token,
				syllableCount,
				partsPerMillion,
				isAdjective,
				isAdverb,
				isNoun,
				isVerb
			FROM
				word
			WHERE
				TRUE

			<cfif ! isNull( token )>
				AND
					token = <cfqueryparam value="#token#" cfsqltype="cf_sql_varchar" />
			</cfif>

			ORDER BY
				<cfswitch expression="#withSort#">
					<cfdefaultcase>
						token ASC
					</cfdefaultcase>
				</cfswitch>
		</cfquery>

		<cfreturn results />

	</cffunction>

</cfcomponent>
