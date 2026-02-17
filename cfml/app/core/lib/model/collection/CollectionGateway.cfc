<cfcomponent extends="core.lib.model.BaseGateway">

	<cffunction name="init" returnType="void">

		<cfset super.init(
			indexPrefixes = [
				"id",
				"userID"
			]
		) />

	</cffunction>

	<!--- PUBLIC METHODS. --->

	<cffunction name="create" returnType="numeric">

		<cfargument name="userID" type="numeric" required="true" />
		<cfargument name="name" type="string" required="true" />
		<cfargument name="descriptionMarkdown" type="string" required="true" />
		<cfargument name="descriptionHtml" type="string" required="true" />
		<cfargument name="createdAt" type="date" required="true" />
		<cfargument name="updatedAt" type="date" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			INSERT INTO
				collection
			SET
				userID = <cfqueryparam value="#userID#" cfsqltype="cf_sql_bigint" />,
				name = <cfqueryparam value="#name#" cfsqltype="cf_sql_varchar" />,
				descriptionMarkdown = <cfqueryparam value="#descriptionMarkdown#" cfsqltype="cf_sql_longvarchar" />,
				descriptionHtml = <cfqueryparam value="#descriptionHtml#" cfsqltype="cf_sql_longvarchar" />,
				createdAt = <cfqueryparam value="#createdAt#" cfsqltype="cf_sql_timestamp" />,
				updatedAt = <cfqueryparam value="#updatedAt#" cfsqltype="cf_sql_timestamp" />
		</cfquery>

		<cfreturn val( metaResults.generatedKey ) />

	</cffunction>


	<cffunction name="deleteByFilter" returnType="void">

		<cfargument name="id" type="numeric" required="false" />
		<cfargument name="userID" type="numeric" required="false" />

		<cfset assertIndexPrefix( arguments ) />

		<cfquery name="local.results" result="local.metaResults">
			DELETE FROM
				collection
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
		<cfargument name="withSort" type="string" required="false" default="id" />

		<cfset assertIndexPrefix( arguments ) />

		<cfquery name="local.results" result="local.metaResults" returnType="array">
			SELECT
				id,
				userID,
				name,
				descriptionMarkdown,
				descriptionHtml,
				createdAt,
				updatedAt
			FROM
				collection
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
				<cfswitch expression="#withSort#">
					<cfcase value="name">
						name ASC,
						id ASC
					</cfcase>
					<cfdefaultcase>
						id ASC
					</cfdefaultcase>
				</cfswitch>
		</cfquery>

		<cfreturn results />

	</cffunction>


	<cffunction name="update" returnType="void">

		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="name" type="string" required="true" />
		<cfargument name="descriptionMarkdown" type="string" required="true" />
		<cfargument name="descriptionHtml" type="string" required="true" />
		<cfargument name="updatedAt" type="date" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			UPDATE
				collection
			SET
				name = <cfqueryparam value="#name#" cfsqltype="cf_sql_varchar" />,
				descriptionMarkdown = <cfqueryparam value="#descriptionMarkdown#" cfsqltype="cf_sql_longvarchar" />,
				descriptionHtml = <cfqueryparam value="#descriptionHtml#" cfsqltype="cf_sql_longvarchar" />,
				updatedAt = <cfqueryparam value="#updatedAt#" cfsqltype="cf_sql_timestamp" />
			WHERE
				id = <cfqueryparam value="#id#" cfsqltype="cf_sql_bigint" />
		</cfquery>

	</cffunction>

</cfcomponent>
