<cfcomponent extends="core.lib.model.BaseGateway">

	<cffunction name="init" returnType="void">

		<cfset super.init(
			indexPrefixes = [
				"userID",
			]
		) />

	</cffunction>

	<!--- PUBLIC METHODS. --->

	<cffunction name="create" returnType="void">

		<cfargument name="userID" type="numeric" required="true" />
		<cfargument name="createdAt" type="date" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			INSERT INTO
				user_account
			SET
				userID = <cfqueryparam value="#userID#" cfsqltype="cf_sql_bigint" />,
				createdAt = <cfqueryparam value="#createdAt#" cfsqltype="cf_sql_timestamp" />
		</cfquery>

	</cffunction>


	<cffunction name="deleteByFilter" returnType="void">

		<cfargument name="userID" type="numeric" required="false" />

		<cfset assertIndexPrefix( arguments ) />

		<cfquery name="local.results" result="local.metaResults">
			DELETE FROM
				user_account
			WHERE
				TRUE

			<cfif ! isNull( id )>
				AND
					id = <cfqueryparam value="#id#" cfsqltype="cf_sql_bigint" />
			</cfif>

			<cfif ! isNull( email )>
				AND
					email = <cfqueryparam value="#email#" cfsqltype="cf_sql_varchar" />
			</cfif>
		</cfquery>

	</cffunction>


	<cffunction name="getByFilter" returnType="array">

		<cfargument name="userID" type="numeric" required="false" />

		<cfset assertIndexPrefix( arguments ) />

		<cfquery name="local.results" result="local.metaResults" returnType="array">
			SELECT
				userID,
				createdAt
			FROM
				user_account
			WHERE
				TRUE

			<cfif ! isNull( userID )>
				AND
					userID = <cfqueryparam value="#userID#" cfsqltype="cf_sql_bigint" />
			</cfif>
		</cfquery>

		<cfreturn results />

	</cffunction>

</cfcomponent>
