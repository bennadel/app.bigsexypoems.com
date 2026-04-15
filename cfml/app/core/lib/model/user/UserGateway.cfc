<cfcomponent extends="core.lib.model.BaseGateway">

	<cffunction name="init" returnType="void">

		<cfset super.init(
			indexPrefixes = [
				"id",
				"email",
			]
		) />

	</cffunction>

	<!--- PUBLIC METHODS. --->

	<cffunction name="create" returnType="numeric">

		<cfargument name="name" type="string" required="true" />
		<cfargument name="email" type="string" required="true" />
		<cfargument name="createdAt" type="date" required="true" />
		<cfargument name="updatedAt" type="date" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			INSERT INTO
				user
			SET
				name = <cfqueryparam value="#name#" cfsqltype="varchar" />,
				email = <cfqueryparam value="#email#" cfsqltype="varchar" />,
				createdAt = <cfqueryparam value="#createdAt#" cfsqltype="timestamp" />,
				updatedAt = <cfqueryparam value="#updatedAt#" cfsqltype="timestamp" />
		</cfquery>

		<cfreturn val( metaResults.generatedKey ) />

	</cffunction>


	<cffunction name="deleteByFilter" returnType="void">

		<cfargument name="id" type="numeric" required="false" />
		<cfargument name="email" type="string" required="false" />

		<cfset assertIndexPrefix( arguments ) />

		<cfquery name="local.results" result="local.metaResults">
			DELETE FROM
				user
			WHERE
				TRUE

			<cfif ! isNull( id )>
				AND
					id = <cfqueryparam value="#id#" cfsqltype="bigint" />
			</cfif>

			<cfif ! isNull( email )>
				AND
					email = <cfqueryparam value="#email#" cfsqltype="varchar" />
			</cfif>
		</cfquery>

	</cffunction>


	<cffunction name="getByFilter" returnType="array">

		<cfargument name="id" type="numeric" required="false" />
		<cfargument name="email" type="string" required="false" />
		<cfargument name="withSort" type="string" required="false" default="id" />
		<cfargument name="withLock" type="string" required="false" default="" />

		<cfset assertIndexPrefix( arguments ) />

		<cfquery name="local.results" result="local.metaResults" returnType="array">
			SELECT
				id,
				name,
				email,
				createdAt
			FROM
				user
			WHERE
				TRUE

			<cfif ! isNull( id )>
				AND
					id = <cfqueryparam value="#id#" cfsqltype="bigint" />
			</cfif>

			<cfif ! isNull( email )>
				AND
					email = <cfqueryparam value="#email#" cfsqltype="varchar" />
			</cfif>

			ORDER BY
				<cfswitch expression="#withSort#">
					<cfdefaultcase>
						id ASC
					</cfdefaultcase>
				</cfswitch>

			<cfswitch expression="#withLock#">
				<cfcase value="readonly">
					FOR SHARE
				</cfcase>
				<cfcase value="exclusive">
					FOR UPDATE
				</cfcase>
			</cfswitch>
		</cfquery>

		<cfreturn results />

	</cffunction>


	<cffunction name="update" returnType="void">

		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="name" type="string" required="true" />
		<cfargument name="email" type="string" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			UPDATE
				user
			SET
				name = <cfqueryparam value="#name#" cfsqltype="varchar" />,
				email = <cfqueryparam value="#email#" cfsqltype="varchar" />
			WHERE
				id = <cfqueryparam value="#id#" cfsqltype="bigint" />
		</cfquery>

	</cffunction>

</cfcomponent>
