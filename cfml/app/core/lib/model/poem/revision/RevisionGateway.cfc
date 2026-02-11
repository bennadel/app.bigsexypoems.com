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
		<cfargument name="name" type="string" required="true" />
		<cfargument name="content" type="string" required="true" />
		<cfargument name="createdAt" type="date" required="true" />
		<cfargument name="updatedAt" type="date" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			INSERT INTO
				poem_revision
			SET
				poemID = <cfqueryparam value="#poemID#" cfsqltype="cf_sql_bigint" />,
				name = <cfqueryparam value="#name#" cfsqltype="cf_sql_varchar" />,
				content = <cfqueryparam value="#content#" cfsqltype="cf_sql_varchar" />,
				createdAt = <cfqueryparam value="#createdAt#" cfsqltype="cf_sql_timestamp" />,
				updatedAt = <cfqueryparam value="#updatedAt#" cfsqltype="cf_sql_timestamp" />
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
				name,
				content,
				createdAt,
				updatedAt
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
				updatedAt DESC
		</cfquery>

		<cfreturn results />

	</cffunction>


	<cffunction name="getMostRecentByPoemID" returnType="array">

		<cfargument name="poemID" type="numeric" required="true" />

		<cfquery name="local.results" result="local.metaResults" returnType="array">
			SELECT
				id,
				poemID,
				name,
				content,
				createdAt,
				updatedAt
			FROM
				poem_revision
			WHERE
				poemID = <cfqueryparam value="#poemID#" cfsqltype="cf_sql_bigint" />
			ORDER BY
				updatedAt DESC
			LIMIT
				1
		</cfquery>

		<cfreturn results />

	</cffunction>


	<cffunction name="update" returnType="void">

		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="name" type="string" required="true" />
		<cfargument name="content" type="string" required="true" />
		<cfargument name="updatedAt" type="date" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			UPDATE
				poem_revision
			SET
				name = <cfqueryparam value="#name#" cfsqltype="cf_sql_varchar" />,
				content = <cfqueryparam value="#content#" cfsqltype="cf_sql_varchar" />,
				updatedAt = <cfqueryparam value="#updatedAt#" cfsqltype="cf_sql_timestamp" />
			WHERE
				id = <cfqueryparam value="#id#" cfsqltype="cf_sql_bigint" />
		</cfquery>

	</cffunction>

</cfcomponent>
