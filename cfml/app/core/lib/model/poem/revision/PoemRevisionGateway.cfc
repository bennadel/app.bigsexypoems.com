<cfcomponent extends="core.lib.model.BaseGateway">

	<cffunction name="init" returnType="void">

		<cfset super.init(
			indexPrefixes = [
				"id",
				"poemID",
			]
		) />

	</cffunction>

	<!--- PUBLIC METHODS. --->

	<cffunction name="create" returnType="numeric">

		<cfargument name="poemID" type="numeric" required="true" />
		<cfargument name="revisionNumber" type="numeric" required="true" />
		<cfargument name="content" type="string" required="true" />
		<cfargument name="createdAt" type="date" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			INSERT INTO
				poem_revision
			SET
				poemID = <cfqueryparam value="#poemID#" cfsqltype="cf_sql_bigint" />,
				revisionNumber = <cfqueryparam value="#revisionNumber#" cfsqltype="cf_sql_integer" />,
				content = <cfqueryparam value="#content#" cfsqltype="cf_sql_varchar" />,
				createdAt = <cfqueryparam value="#createdAt#" cfsqltype="cf_sql_timestamp" />
		</cfquery>

		<cfreturn val( metaResults.generatedKey ) />

	</cffunction>


	<cffunction name="deleteByFilter" returnType="void">

		<cfargument name="id" type="numeric" required="false" />
		<cfargument name="poemID" type="numeric" required="false" />

		<cfset assertIndexPrefix( arguments ) />

		<cfquery name="local.results" result="local.metaResults">
			DELETE FROM
				poem_revision
			WHERE
				TRUE

			<cfif ! isNull( id )>
				AND
					id = <cfqueryparam value="#id#" cfsqltype="cf_sql_bigint" />
			</cfif>

			<cfif ! isNull( poemID )>
				AND
					poemID = <cfqueryparam value="#poemID#" cfsqltype="cf_sql_bigint" />
			</cfif>
		</cfquery>

	</cffunction>


	<cffunction name="getByFilter" returnType="array">

		<cfargument name="id" type="numeric" required="false" />
		<cfargument name="poemID" type="numeric" required="false" />

		<cfset assertIndexPrefix( arguments ) />

		<cfquery name="local.results" result="local.metaResults" returnType="array">
			SELECT
				id,
				poemID,
				revisionNumber,
				content,
				createdAt
			FROM
				poem_revision
			WHERE
				TRUE

			<cfif ! isNull( id )>
				AND
					id = <cfqueryparam value="#id#" cfsqltype="cf_sql_bigint" />
			</cfif>

			<cfif ! isNull( poemID )>
				AND
					poemID = <cfqueryparam value="#poemID#" cfsqltype="cf_sql_bigint" />
			</cfif>

			ORDER BY
				revisionNumber ASC
		</cfquery>

		<cfreturn results />

	</cffunction>


	<cffunction name="getLatestByPoemID" returnType="array">

		<cfargument name="poemID" type="numeric" required="true" />

		<cfquery name="local.results" result="local.metaResults" returnType="array">
			SELECT
				id,
				poemID,
				revisionNumber,
				content,
				createdAt
			FROM
				poem_revision
			WHERE
				poemID = <cfqueryparam value="#poemID#" cfsqltype="cf_sql_bigint" />
			ORDER BY
				revisionNumber DESC
			LIMIT
				1
		</cfquery>

		<cfreturn results />

	</cffunction>


	<cffunction name="getNextRevisionNumber" returnType="numeric">

		<cfargument name="poemID" type="numeric" required="true" />

		<cfquery name="local.results" result="local.metaResults" returnType="array">
			SELECT
				( COALESCE( MAX( revisionNumber ), 0 ) + 1 ) AS nextRevisionNumber
			FROM
				poem_revision
			WHERE
				poemID = <cfqueryparam value="#poemID#" cfsqltype="cf_sql_bigint" />
		</cfquery>

		<cfreturn val( results[ 1 ].nextRevisionNumber ) />

	</cffunction>

</cfcomponent>
