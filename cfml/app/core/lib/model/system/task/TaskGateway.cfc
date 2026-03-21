<cfcomponent extends="core.lib.model.BaseGateway">

	<cffunction name="init" returnType="void">

		<cfset super.init(
			indexPrefixes = [],
			decodeMappings = {
				isDailyTask: "boolean",
				state: "json",
			}
		) />

	</cffunction>

	<!--- PUBLIC METHODS. --->

	<cffunction name="getByFilter" returnType="array">

		<cfargument name="id" type="string" required="false" />
		<cfargument name="overdueAt" type="date" required="false" />
		<cfargument name="withSort" type="string" required="false" default="id" />

		<cfquery name="local.results" result="local.metaResults" returnType="array">
			SELECT
				id,
				description,
				isDailyTask,
				timeOfDay,
				intervalInMinutes,
				state,
				lastExecutedAt,
				nextExecutedAt
			FROM
				scheduled_task
			WHERE
				TRUE

			<cfif ! isNull( id )>
				AND
					id = <cfqueryparam value="#id#" cfsqltype="varchar" />
			</cfif>

			<cfif ! isNull( overdueAt )>
				AND
					nextExecutedAt <= <cfqueryparam value="#overdueAt#" cfsqltype="timestamp" />
			</cfif>

			ORDER BY
				<cfswitch expression="#withSort#">
					<cfdefaultcase>
						id ASC
					</cfdefaultcase>
				</cfswitch>
		</cfquery>

		<cfreturn decodeColumns( results ) />

	</cffunction>


	<cffunction name="update" returnType="void">

		<cfargument name="id" type="string" required="true" />
		<cfargument name="state" type="struct" required="true" />
		<cfargument name="lastExecutedAt" type="date" required="true" />
		<cfargument name="nextExecutedAt" type="date" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			UPDATE
				scheduled_task
			SET
				state = <cfqueryparam value="#serializeJson( state )#" cfsqltype="varchar" />,
				lastExecutedAt = <cfqueryparam value="#lastExecutedAt#" cfsqltype="timestamp" />,
				nextExecutedAt = <cfqueryparam value="#nextExecutedAt#" cfsqltype="timestamp" />
			WHERE
				id = <cfqueryparam value="#id#" cfsqltype="varchar" />
		</cfquery>

	</cffunction>

</cfcomponent>
