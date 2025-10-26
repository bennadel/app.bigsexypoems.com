<cfcomponent extends="core.lib.model.BaseGateway">

	<cffunction name="getPoems" returnType="array">

		<cfargument name="userID" type="numeric" />

		<cfquery name="local.results" result="local.metaResults" returnType="array">
			#DEBUGGING_COMMENT#
			SELECT
				p.id,
				p.name,
				p.updatedAt,
				( t.id ) AS tag_id,
				( t.name ) AS tag_name
			FROM
				poem p
			LEFT OUTER JOIN
				tag t
			ON
				t.id = p.tagID
			WHERE
				p.userID = <cfqueryparam value="#userID#" cfsqltype="cf_sql_bigint" />
			ORDER BY
				p.name ASC,
				p.id ASC
		</cfquery>

		<cfreturn normalizeCrossJoin( results ) />

	</cffunction>

</cfcomponent>
