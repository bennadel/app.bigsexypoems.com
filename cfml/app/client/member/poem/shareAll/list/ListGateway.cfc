<cfcomponent extends="core.lib.model.BaseGateway">

	<cffunction name="getShares" returnType="array">

		<cfargument name="userID" type="numeric" />

		<cfquery name="local.results" result="local.metaResults" returnType="array">
			#DEBUGGING_COMMENT#
			SELECT
				<!--- Poem data. --->
				p.id AS poem_id,
				p.name AS poem_name,

				<!--- Share data. --->
				s.id AS share_id,
				s.token AS share_token,
				s.name AS share_name,
				s.noteMarkdown AS share_noteMarkdown,
				s.viewingCount AS share_viewingCount,
				s.createdAt AS share_createdAt
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
				poem_name ASC,
				poem_id ASC,
				share_id ASC
		</cfquery>

		<cfreturn normalizeCrossProduct( results ) />

	</cffunction>

</cfcomponent>
