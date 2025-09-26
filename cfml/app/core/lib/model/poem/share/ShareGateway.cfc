<cfcomponent output="false">

	<cffunction name="create" returnType="numeric">

		<cfargument name="poemID" type="numeric" required="true" />
		<cfargument name="token" type="string" required="true" />
		<cfargument name="name" type="string" required="true" />
		<cfargument name="noteMarkdown" type="string" required="true" />
		<cfargument name="noteHtml" type="string" required="true" />
		<cfargument name="viewingCount" type="numeric" required="true" />
		<cfargument name="createdAt" type="date" required="true" />
		<cfargument name="updatedAt" type="date" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			INSERT INTO
				poem_share
			SET
				poemID = <cfqueryparam value="#poemID#" cfsqltype="cf_sql_bigint" />,
				token = <cfqueryparam value="#token#" cfsqltype="cf_sql_varchar" />,
				name = <cfqueryparam value="#name#" cfsqltype="cf_sql_varchar" />,
				noteMarkdown = <cfqueryparam value="#noteMarkdown#" cfsqltype="cf_sql_longvarchar" />,
				noteHtml = <cfqueryparam value="#noteHtml#" cfsqltype="cf_sql_longvarchar" />,
				viewingCount = <cfqueryparam value="#viewingCount#" cfsqltype="cf_sql_bigint" />,
				createdAt = <cfqueryparam value="#createdAt#" cfsqltype="cf_sql_timestamp" />,
				updatedAt = <cfqueryparam value="#updatedAt#" cfsqltype="cf_sql_timestamp" />
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
				name,
				noteMarkdown,
				noteHtml,
				viewingCount,
				createdAt,
				updatedAt
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


	<cffunction name="update" returnType="void">

		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="name" type="string" required="true" />
		<cfargument name="noteMarkdown" type="string" required="true" />
		<cfargument name="noteHtml" type="string" required="true" />
		<cfargument name="viewingCount" type="numeric" required="true" />
		<cfargument name="updatedAt" type="date" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			UPDATE
				poem_share
			SET
				name = <cfqueryparam value="#name#" cfsqltype="cf_sql_varchar" />,
				noteMarkdown = <cfqueryparam value="#noteMarkdown#" cfsqltype="cf_sql_longvarchar" />,
				noteHtml = <cfqueryparam value="#noteHtml#" cfsqltype="cf_sql_longvarchar" />,
				viewingCount = <cfqueryparam value="#viewingCount#" cfsqltype="cf_sql_bigint" />,
				updatedAt = <cfqueryparam value="#updatedAt#" cfsqltype="cf_sql_timestamp" />
			WHERE
				id = <cfqueryparam value="#id#" cfsqltype="cf_sql_bigint" />
			;
		</cfquery>

	</cffunction>

</cfcomponent>
