<cfcomponent output="false">

	<cffunction name="create" returnType="numeric">

		<cfargument name="poemID" type="numeric" required="true" />
		<cfargument name="shareID" type="numeric" required="true" />
		<cfargument name="ipAddress" type="string" required="true" />
		<cfargument name="ipCity" type="string" required="true" />
		<cfargument name="ipRegion" type="string" required="true" />
		<cfargument name="ipCountry" type="string" required="true" />
		<cfargument name="createdAt" type="date" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			INSERT INTO
				poem_share_viewing
			SET
				poemID = <cfqueryparam value="#poemID#" cfsqltype="cf_sql_bigint" />,
				shareID = <cfqueryparam value="#shareID#" cfsqltype="cf_sql_bigint" />,
				ipAddress = <cfqueryparam value="#ipAddress#" cfsqltype="cf_sql_varchar" />,
				ipCity = <cfqueryparam value="#ipCity#" cfsqltype="cf_sql_varchar" />,
				ipRegion = <cfqueryparam value="#ipRegion#" cfsqltype="cf_sql_varchar" />,
				ipCountry = <cfqueryparam value="#ipCountry#" cfsqltype="cf_sql_varchar" />,
				createdAt = <cfqueryparam value="#createdAt#" cfsqltype="cf_sql_timestamp" />
		</cfquery>

		<cfreturn val( metaResults.generatedKey ) />

	</cffunction>


	<cffunction name="deleteByFilter" returnType="void">

		<cfargument name="id" type="numeric" required="false" />
		<cfargument name="poemID" type="numeric" required="false" />
		<cfargument name="shareID" type="numeric" required="false" />

		<cfif (
			isNull( id ) &&
			isNull( poemID )
			)>

			<cfthrow type="Gateway.ForbiddenSql" />

		</cfif>

		<cfquery name="local.results" result="local.metaResults">
			DELETE FROM
				poem_share_viewing
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

			<cfif ! isNull( shareID )>
				AND
					shareID = <cfqueryparam value="#shareID#" cfsqltype="cf_sql_bigint" />
			</cfif>
		</cfquery>

	</cffunction>


	<cffunction name="getCountByFilter" returnType="numeric">

		<cfargument name="poemID" type="numeric" required="false" />
		<cfargument name="shareID" type="numeric" required="false" />
		<cfargument name="ipAddress" type="numeric" required="false" />

		<cfif isNull( poemID )>

			<cfthrow type="Gateway.ForbiddenSql" />

		</cfif>

		<cfquery name="local.results" result="local.metaResults">
			SELECT
				COUNT( * ) AS rowCount
			FROM
				poem_share_viewing
			WHERE
				TRUE

			<cfif ! isNull( poemID )>
				AND
					poemID = <cfqueryparam value="#poemID#" cfsqltype="cf_sql_bigint" />
			</cfif>

			<cfif ! isNull( shareID )>
				AND
					shareID = <cfqueryparam value="#shareID#" cfsqltype="cf_sql_bigint" />
			</cfif>

			<cfif ! isNull( ipAddress )>
				AND
					ipAddress = <cfqueryparam value="#ipAddress#" cfsqltype="cf_sql_string" />
			</cfif>

		</cfquery>

		<cfreturn results.rowCount />

	</cffunction>


	<cffunction name="getByFilter" returnType="array">

		<cfargument name="id" type="numeric" required="false" />
		<cfargument name="poemID" type="numeric" required="false" />
		<cfargument name="shareID" type="numeric" required="false" />
		<cfargument name="ipAddress" type="string" required="false" />

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
				shareID,
				ipAddress,
				ipCity,
				ipRegion,
				ipCountry,
				createdAt
			FROM
				poem_share_viewing
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

			<cfif ! isNull( shareID )>
				AND
					shareID = <cfqueryparam value="#shareID#" cfsqltype="cf_sql_bigint" />
			</cfif>

			<cfif ! isNull( ipAddress )>
				AND
					ipAddress = <cfqueryparam value="#ipAddress#" cfsqltype="cf_sql_string" />
			</cfif>

			ORDER BY
				id ASC
		</cfquery>

		<cfreturn results />

	</cffunction>

</cfcomponent>
