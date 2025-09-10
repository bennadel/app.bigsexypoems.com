<cfcomponent output="false">

	<cffunction name="getSessions" returnType="array">

		<cfargument name="userID" type="numeric" />

		<cfquery name="local.results" result="local.metaResults" returnType="array">
			/* DEBUG: client.member.sessions.list.ListGateway. */
			SELECT
				s.id,
				s.isAuthenticated,
				s.ipAddress,
				s.createdAt,
				p.requestCount,
				p.lastRequestAt
			FROM
				user_session s
			INNER JOIN
				user_session_presence p
			ON
				(
						s.userID = <cfqueryparam value="#userID#" cfsqltype="cf_sql_bigint" />
					AND
						p.sessionID = s.id
				)
			ORDER BY
				p.lastRequestAt DESC,
				s.id DESC
		</cfquery>

		<cfreturn results />

	</cffunction>

</cfcomponent>
