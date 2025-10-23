<cfcomponent output="false">

	<cffunction name="create" returnType="numeric">

		<cfargument name="userID" type="numeric" required="true" />
		<cfargument name="name" type="string" required="true" />
		<cfargument name="slug" type="string" required="true" />
		<cfargument name="fillHex" type="string" required="true" />
		<cfargument name="textHex" type="string" required="true" />
		<cfargument name="createdAt" type="date" required="true" />
		<cfargument name="updatedAt" type="date" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			INSERT INTO
				tag
			SET
				userID = <cfqueryparam value="#userID#" cfsqltype="cf_sql_bigint" />,
				name = <cfqueryparam value="#name#" cfsqltype="cf_sql_varchar" />,
				slug = <cfqueryparam value="#slug#" cfsqltype="cf_sql_varchar" />,
				fillHex = <cfqueryparam value="#fillHex#" cfsqltype="cf_sql_varchar" />,
				textHex = <cfqueryparam value="#textHex#" cfsqltype="cf_sql_varchar" />,
				createdAt = <cfqueryparam value="#createdAt#" cfsqltype="cf_sql_timestamp" />,
				updatedAt = <cfqueryparam value="#updatedAt#" cfsqltype="cf_sql_timestamp" />
		</cfquery>

		<cfreturn val( metaResults.generatedKey ) />

	</cffunction>


	<cffunction name="deleteByFilter" returnType="void">

		<cfargument name="id" type="numeric" required="false" />
		<cfargument name="userID" type="numeric" required="false" />

		<cfif (
			isNull( id ) &&
			isNull( userID )
			)>

			<cfthrow type="Gateway.ForbiddenSql" />

		</cfif>

		<cfquery name="local.results" result="local.metaResults">
			DELETE FROM
				tag
			WHERE
				TRUE

			<cfif ! isNull( id )>
				AND
					id = <cfqueryparam value="#id#" cfsqltype="cf_sql_bigint" />
			</cfif>

			<cfif ! isNull( userID )>
				AND
					userID = <cfqueryparam value="#userID#" cfsqltype="cf_sql_bigint" />
			</cfif>
		</cfquery>

	</cffunction>


	<cffunction name="getByFilter" returnType="array">

		<cfargument name="id" type="numeric" required="false" />
		<cfargument name="userID" type="numeric" required="false" />

		<cfif (
			isNull( id ) &&
			isNull( userID )
			)>

			<cfthrow type="Gateway.ForbiddenSql" />

		</cfif>

		<cfquery name="local.results" result="local.metaResults" returnType="array">
			SELECT
				id,
				userID,
				name,
				slug,
				fillHex,
				textHex,
				createdAt,
				updatedAt
			FROM
				tag
			WHERE
				TRUE

			<cfif ! isNull( id )>
				AND
					id = <cfqueryparam value="#id#" cfsqltype="cf_sql_bigint" />
			</cfif>

			<cfif ! isNull( userID )>
				AND
					userID = <cfqueryparam value="#userID#" cfsqltype="cf_sql_bigint" />
			</cfif>

			ORDER BY
				id ASC
		</cfquery>

		<cfreturn results />

	</cffunction>


	<cffunction name="update" returnType="void">

		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="name" type="string" required="true" />
		<cfargument name="slug" type="string" required="true" />
		<cfargument name="fillHex" type="string" required="true" />
		<cfargument name="textHex" type="string" required="true" />
		<cfargument name="updatedAt" type="date" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			UPDATE
				tag
			SET
				name = <cfqueryparam value="#name#" cfsqltype="cf_sql_varchar" />,
				slug = <cfqueryparam value="#slug#" cfsqltype="cf_sql_varchar" />,
				fillHex = <cfqueryparam value="#fillHex#" cfsqltype="cf_sql_varchar" />,
				textHex = <cfqueryparam value="#textHex#" cfsqltype="cf_sql_varchar" />,
				updatedAt = <cfqueryparam value="#updatedAt#" cfsqltype="cf_sql_timestamp" />
			WHERE
				id = <cfqueryparam value="#id#" cfsqltype="cf_sql_bigint" />
		</cfquery>

	</cffunction>

</cfcomponent>
