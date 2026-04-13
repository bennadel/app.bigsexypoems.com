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
				userID = <cfqueryparam value="#userID#" cfsqltype="bigint" />,
				createdAt = <cfqueryparam value="#createdAt#" cfsqltype="timestamp" />
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

			<cfif ! isNull( userID )>
				AND
					userID = <cfqueryparam value="#userID#" cfsqltype="integer" />
			</cfif>
		</cfquery>

	</cffunction>


	<cffunction name="getByFilter" returnType="array">

		<cfargument name="userID" type="numeric" required="false" />
		<cfargument name="withLock" type="string" required="false" default="" />

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
					userID = <cfqueryparam value="#userID#" cfsqltype="bigint" />
			</cfif>

			<cfswitch expression="#withLock#">
				<cfcase value="readonly">
					FOR SHARE
				</cfcase>
				<cfcase value="exclusive">
					FOR UPDATE
				</cfcase>
			</cfswitch>
		</cfquery>

		<cfreturn results />

	</cffunction>

</cfcomponent>
