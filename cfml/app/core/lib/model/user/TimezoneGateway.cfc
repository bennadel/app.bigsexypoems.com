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
		<cfargument name="offsetInMinutes" type="numeric" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			INSERT INTO
				user_timezone
			SET
				userID = <cfqueryparam value="#userID#" cfsqltype="bigint" />,
				offsetInMinutes = <cfqueryparam value="#offsetInMinutes#" cfsqltype="integer" />
		</cfquery>

	</cffunction>


	<cffunction name="deleteByFilter" returnType="void">

		<cfargument name="userID" type="numeric" required="false" />

		<cfset assertIndexPrefix( arguments ) />

		<cfquery name="local.results" result="local.metaResults">
			DELETE FROM
				user_timezone
			WHERE
				TRUE

			<cfif ! isNull( userID )>
				AND
					userID = <cfqueryparam value="#userID#" cfsqltype="bigint" />
			</cfif>
		</cfquery>

	</cffunction>


	<cffunction name="getByFilter" returnType="array">

		<cfargument name="userID" type="numeric" required="false" />

		<cfset assertIndexPrefix( arguments ) />

		<cfquery name="local.results" result="local.metaResults" returnType="array">
			SELECT
				userID,
				offsetInMinutes
			FROM
				user_timezone
			WHERE
				TRUE

			<cfif ! isNull( userID )>
				AND
					userID = <cfqueryparam value="#userID#" cfsqltype="bigint" />
			</cfif>
		</cfquery>

		<cfreturn results />

	</cffunction>


	<cffunction name="update" returnType="void">

		<cfargument name="userID" type="numeric" required="true" />
		<cfargument name="offsetInMinutes" type="numeric" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			UPDATE
				user_timezone
			SET
				offsetInMinutes = <cfqueryparam value="#offsetInMinutes#" cfsqltype="integer" />
			WHERE
				userID = <cfqueryparam value="#userID#" cfsqltype="bigint" />
		</cfquery>

	</cffunction>

</cfcomponent>
