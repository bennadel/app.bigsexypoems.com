<cfcomponent extends="core.lib.model.BaseGateway">

	<cffunction name="getPoems" returnType="array">

		<cfargument name="userID" type="numeric" />

		<cfquery name="local.results" result="local.metaResults" returnType="array">
			#DEBUGGING_COMMENT#
			SELECT
				p.id,
				p.name,
				p.updatedAt,
				( c.id ) AS collection_id,
				( c.name ) AS collection_name
			FROM
				poem p
			LEFT OUTER JOIN
				collection c
			ON
				c.id = p.collectionID
			WHERE
				p.userID = <cfqueryparam value="#userID#" cfsqltype="cf_sql_bigint" />
			ORDER BY
				p.name ASC,
				p.id ASC
		</cfquery>

		<cfreturn normalizeCrossJoin( results ) />

	</cffunction>

</cfcomponent>
