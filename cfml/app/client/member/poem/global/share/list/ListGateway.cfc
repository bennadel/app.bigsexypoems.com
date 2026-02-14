<cfcomponent extends="core.lib.web.BasePartialGateway">

	<cffunction name="getShares" returnType="array">

		<cfargument name="userID" type="numeric" />

		<cfquery name="local.results" result="local.metaResults" returnType="array">
			#DEBUGGING_COMMENT#
			SELECT
				<!--- Share data. --->
				s.id,
				s.token,
				s.name,
				s.noteMarkdown,
				s.viewingCount,
				s.lastViewingAt,
				s.createdAt,

				<!--- Poem data. --->
				p.id AS poem_id,
				p.name AS poem_name
			FROM
				poem p
			INNER JOIN
				poem_share s
			ON
				(
						p.userID = <cfqueryparam value="#userID#" cfsqltype="cf_sql_bigint" />
					AND
						s.poemID = p.id
				)
			ORDER BY
				s.lastViewingAt DESC,
				s.id DESC
		</cfquery>

		<cfreturn normalizeCrossJoin( results ) />

	</cffunction>

</cfcomponent>
