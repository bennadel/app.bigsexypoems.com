<cfcomponent output="false">

	<cffunction name="create" returnType="numeric">

		<cfargument name="poemID" type="numeric" required="true" />
		<cfargument name="token" type="string" required="true" />
		<cfargument name="createdAt" type="date" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			INSERT INTO
				poem_share
			SET
				poemID = <cfqueryparam value="#poemID#" cfsqltype="cf_sql_bigint" />,
				token = <cfqueryparam value="#token#" cfsqltype="cf_sql_varchar" />,
				createdAt = <cfqueryparam value="#createdAt#" cfsqltype="cf_sql_timestamp" />
			;
		</cfquery>

		<cfreturn val( metaResults.generatedKey ) />

	</cffunction>


	<cffunction name="deleteByFilter" returnType="void">

		<cfargument name="id" type="numeric" required="false" />
		<cfargument name="poemID" type="numeric" required="false" />

		<cfif (
			isNull( id ) &&
			isNull( poemID )
			)>

			<cfthrow type="Gateway.ForbiddenSql" />

		</cfif>

		<cfquery name="local.results" result="local.metaResults">
			DELETE FROM
				poem_share
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
			;
		</cfquery>

	</cffunction>


	<cffunction name="getByFilter" returnType="array">

		<cfargument name="id" type="numeric" required="false" />
		<cfargument name="poemID" type="numeric" required="false" />
		<cfargument name="token" type="string" required="false" />

		<cfif (
			isNull( id ) &&
			isNull( poemID )
			)>

			<cfthrow type="Gateway.ForbiddenSql" />

		</cfif>

		<cfquery name="local.results" result="local.metaResults" returnType="array">
			SELECT
				id,
				poemID,
				token,
				createdAt
			FROM
				poem_share
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

			<cfif ! isNull( token )>
				AND
					token = <cfqueryparam value="#token#" cfsqltype="cf_sql_string" /> COLLATE utf8mb4_bin
			</cfif>

			ORDER BY
				id ASC
			;
		</cfquery>

		<cfreturn results />

	</cffunction>

</cfcomponent>
