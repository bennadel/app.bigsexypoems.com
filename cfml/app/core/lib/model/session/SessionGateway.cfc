<cfcomponent extends="core.lib.model.BaseGateway">

	<cffunction name="init" returnType="void">

		<cfset super.init(
			indexPrefixes = [
				"id",
				"userID",
			],
			decodeMappings = {
				isAuthenticated: "boolean",
			}
		) />

	</cffunction>

	<!--- PUBLIC METHODS. --->

	<cffunction name="create" returnType="numeric">

		<cfargument name="token" type="string" required="true" />
		<cfargument name="userID" type="numeric" required="true" />
		<cfargument name="isAuthenticated" type="boolean" required="true" />
		<cfargument name="ipAddress" type="string" required="true" />
		<cfargument name="createdAt" type="date" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			INSERT INTO
				user_session
			SET
				token = <cfqueryparam value="#token#" cfsqltype="cf_sql_varchar" />,
				userID = <cfqueryparam value="#userID#" cfsqltype="cf_sql_bigint" />,
				isAuthenticated = <cfqueryparam value="#isAuthenticated#" cfsqltype="cf_sql_tinyint" />,
				ipAddress = <cfqueryparam value="#ipAddress#" cfsqltype="cf_sql_varchar" />,
				createdAt = <cfqueryparam value="#createdAt#" cfsqltype="cf_sql_timestamp" />
		</cfquery>

		<cfreturn val( metaResults.generatedKey ) />

	</cffunction>


	<cffunction name="deleteByFilter" returnType="void">

		<cfargument name="id" type="numeric" required="false" />
		<cfargument name="userID" type="numeric" required="false" />

		<cfset assertIndexPrefix( arguments ) />

		<cfquery name="local.results" result="local.metaResults">
			DELETE FROM
				user_session
			WHERE
				TRUE

			<cfif ! isNull( id )>
				AND
					id = <cfqueryparam value="#id#" cfsqltype="cf_sql_bigint" />
			</cfif>

			<cfif ! isNull( userID )>
				AND
					userID = <cfqueryparam value="#userID#" cfsqltype="cf_sql_bigint" />
			</cfif>
		</cfquery>

	</cffunction>


	<cffunction name="getByFilter" returnType="array">

		<cfargument name="id" type="numeric" required="false" />
		<cfargument name="userID" type="numeric" required="false" />
		<cfargument name="token" type="string" required="false" />

		<cfset assertIndexPrefix( arguments ) />

		<cfquery name="local.results" result="local.metaResults" returnType="array">
			SELECT
				id,
				token,
				userID,
				isAuthenticated,
				ipAddress,
				createdAt
			FROM
				user_session
			WHERE
				TRUE

			<cfif ! isNull( id )>
				AND
					id = <cfqueryparam value="#id#" cfsqltype="cf_sql_bigint" />
			</cfif>

			<cfif ! isNull( userID )>
				AND
					userID = <cfqueryparam value="#userID#" cfsqltype="cf_sql_bigint" />
			</cfif>

			<cfif ! isNull( token )>
				AND
					token = <cfqueryparam value="#token#" cfsqltype="cf_sql_varchar" /> COLLATE utf8mb4_bin
			</cfif>

			ORDER BY
				id ASC
		</cfquery>

		<cfreturn decodeColumns( results ) />

	</cffunction>


	<cffunction name="update" returnType="void">

		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="isAuthenticated" type="boolean" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			UPDATE
				user_session
			SET
				isAuthenticated = <cfqueryparam value="#isAuthenticated#" cfsqltype="cf_sql_tinyint" />
			WHERE
				id = <cfqueryparam value="#id#" cfsqltype="cf_sql_bigint" />
		</cfquery>

	</cffunction>

</cfcomponent>
