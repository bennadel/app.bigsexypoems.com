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
				sessionID = <cfqueryparam value="#sessionID#" cfsqltype="bigint" />,
				requestCount = <cfqueryparam value="#requestCount#" cfsqltype="integer" />,
				lastRequestAt = <cfqueryparam value="#lastRequestAt#" cfsqltype="timestamp" />
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
					sessionID = <cfqueryparam value="#sessionID#" cfsqltype="bigint" />
			</cfif>
		</cfquery>

	</cffunction>


	<cffunction name="getByFilter" returnType="array">

		<cfargument name="sessionID" type="numeric" required="false" />
		<cfargument name="withLock" type="string" required="false" default="" />

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
					sessionID = <cfqueryparam value="#sessionID#" cfsqltype="bigint" />
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


	<cffunction name="logRequest" returnType="void">

		<cfargument name="sessionID" type="numeric" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			UPDATE
				user_session_presence
			SET
				requestCount = ( requestCount + 1 ),
				lastRequestAt = GREATEST( lastRequestAt, UTC_TIMESTAMP() )
			WHERE
				sessionID = <cfqueryparam value="#sessionID#" cfsqltype="bigint" />
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
				requestCount = <cfqueryparam value="#requestCount#" cfsqltype="integer" />,
				lastRequestAt = <cfqueryparam value="#lastRequestAt#" cfsqltype="timestamp" />
			WHERE
				sessionID = <cfqueryparam value="#sessionID#" cfsqltype="bigint" />
		</cfquery>

	</cffunction>

</cfcomponent>
