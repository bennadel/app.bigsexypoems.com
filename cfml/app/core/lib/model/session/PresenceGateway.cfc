<cfcomponent extends="core.lib.model.BaseGateway">

	<cffunction name="init" returnType="void">

		<cfset super.init(
			indexPrefixes = [
				"sessionID",
			]
		) />

	</cffunction>

	<!--- PUBLIC METHODS. --->

	<cffunction name="create" returnType="void">

		<cfargument name="sessionID" type="numeric" required="true" />
		<cfargument name="requestCount" type="numeric" required="true" />
		<cfargument name="lastRequestAt" type="date" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			INSERT INTO
				user_session_presence
			SET
				sessionID = <cfqueryparam value="#sessionID#" cfsqltype="cf_sql_bigint" />,
				requestCount = <cfqueryparam value="#requestCount#" cfsqltype="cf_sql_integer" />,
				lastRequestAt = <cfqueryparam value="#lastRequestAt#" cfsqltype="cf_sql_timestamp" />
		</cfquery>

	</cffunction>


	<cffunction name="deleteByFilter" returnType="void">

		<cfargument name="sessionID" type="numeric" required="false" />

		<cfset assertIndexPrefix( arguments ) />

		<cfquery name="local.results" result="local.metaResults">
			DELETE FROM
				user_session_presence
			WHERE
				TRUE

			<cfif ! isNull( sessionID )>
				AND
					sessionID = <cfqueryparam value="#sessionID#" cfsqltype="cf_sql_bigint" />
			</cfif>
		</cfquery>

	</cffunction>


	<cffunction name="getByFilter" returnType="array">

		<cfargument name="sessionID" type="numeric" required="false" />

		<cfset assertIndexPrefix( arguments ) />

		<cfquery name="local.results" result="local.metaResults" returnType="array">
			SELECT
				sessionID,
				requestCount,
				lastRequestAt
			FROM
				user_session_presence
			WHERE
				TRUE

			<cfif ! isNull( sessionID )>
				AND
					sessionID = <cfqueryparam value="#sessionID#" cfsqltype="cf_sql_bigint" />
			</cfif>
		</cfquery>

		<cfreturn results />

	</cffunction>


	<cffunction name="logRequest" returnType="void">

		<cfargument name="sessionID" type="numeric" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			UPDATE
				user_session_presence
			SET
				requestCount = ( requestCount + 1 ),
				lastRequestAt = GREATEST( lastRequestAt, UTC_TIMESTAMP() )
			WHERE
				sessionID = <cfqueryparam value="#sessionID#" cfsqltype="cf_sql_bigint" />
		</cfquery>

	</cffunction>


	<cffunction name="update" returnType="void">

		<cfargument name="sessionID" type="numeric" required="true" />
		<cfargument name="requestCount" type="numeric" required="true" />
		<cfargument name="lastRequestAt" type="date" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			UPDATE
				user_session_presence
			SET
				requestCount = <cfqueryparam value="#requestCount#" cfsqltype="cf_sql_integer" />,
				lastRequestAt = <cfqueryparam value="#lastRequestAt#" cfsqltype="cf_sql_timestamp" />
			WHERE
				sessionID = <cfqueryparam value="#sessionID#" cfsqltype="cf_sql_bigint" />
		</cfquery>

	</cffunction>

</cfcomponent>
