<cfcomponent extends="core.lib.model.BaseGateway">

	<cffunction name="init" returnType="void">

		<cfset super.init(
			indexPrefixes = [
				"id",
				"expiresAtBefore",
			]
		) />

	</cffunction>

	<!--- PUBLIC METHODS. --->

	<cffunction name="create" returnType="numeric">

		<cfargument name="slug" type="string" required="true" />
		<cfargument name="passcode" type="string" required="true" />
		<cfargument name="value" type="string" required="true" />
		<cfargument name="expiresAt" type="date" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			INSERT INTO
				one_time_token
			SET
				slug = <cfqueryparam value="#slug#" cfsqltype="cf_sql_varchar" />,
				passcode = <cfqueryparam value="#passcode#" cfsqltype="cf_sql_varchar" />,
				value = <cfqueryparam value="#value#" cfsqltype="cf_sql_varchar" />,
				expiresAt = <cfqueryparam value="#expiresAt#" cfsqltype="cf_sql_timestamp" />
		</cfquery>

		<cfreturn val( metaResults.generatedKey ) />

	</cffunction>


	<cffunction name="deleteByFilter" returnType="void">

		<cfargument name="id" type="numeric" required="false" />

		<cfset assertIndexPrefix( arguments ) />

		<cfquery name="local.results" result="local.metaResults">
			DELETE FROM
				one_time_token
			WHERE
				TRUE

			<cfif ! isNull( id )>
				AND
					id = <cfqueryparam value="#id#" cfsqltype="cf_sql_bigint" />
			</cfif>
		</cfquery>

	</cffunction>


	<cffunction name="getByFilter" returnType="array">

		<cfargument name="id" type="numeric" required="false" />
		<cfargument name="expiresAtBefore" type="date" required="false" />
		<cfargument name="withSort" type="string" required="false" default="id" />

		<cfset assertIndexPrefix( arguments ) />

		<cfquery name="local.results" result="local.metaResults" returnType="array">
			SELECT
				id,
				slug,
				passcode,
				value,
				expiresAt
			FROM
				one_time_token
			WHERE
				TRUE

			<cfif ! isNull( id )>
				AND
					id = <cfqueryparam value="#id#" cfsqltype="cf_sql_bigint" />
			</cfif>

			<cfif ! isNull( expiresAtBefore )>
				AND
					expiresAt <= <cfqueryparam value="#expiresAtBefore#" cfsqltype="cf_sql_timestamp" />
			</cfif>

			ORDER BY
				<cfswitch expression="#withSort#">
					<cfdefaultcase>
						id ASC
					</cfdefaultcase>
				</cfswitch>
		</cfquery>

		<cfreturn results />

	</cffunction>

</cfcomponent>
