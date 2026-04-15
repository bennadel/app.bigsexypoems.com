<cfcomponent extends="core.lib.model.BaseGateway">

	<cffunction name="init" returnType="void">

		<cfset super.init(
			indexPrefixes = [
				"id",
				"userID",
			],
			decodeMappings = {
				isAuthenticated: "boolean",
			}
		) />

	</cffunction>

	<!--- PUBLIC METHODS. --->

	<cffunction name="create" returnType="numeric">

		<cfargument name="token" type="string" required="true" />
		<cfargument name="userID" type="numeric" required="true" />
		<cfargument name="isAuthenticated" type="boolean" required="true" />
		<cfargument name="ipAddress" type="string" required="true" />
		<cfargument name="ipCity" type="string" required="true" />
		<cfargument name="ipRegion" type="string" required="true" />
		<cfargument name="ipCountry" type="string" required="true" />
		<cfargument name="createdAt" type="date" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			INSERT INTO
				user_session
			SET
				token = <cfqueryparam value="#token#" cfsqltype="varchar" />,
				userID = <cfqueryparam value="#userID#" cfsqltype="bigint" />,
				isAuthenticated = <cfqueryparam value="#isAuthenticated#" cfsqltype="tinyint" />,
				ipAddress = <cfqueryparam value="#ipAddress#" cfsqltype="varchar" />,
				ipCity = <cfqueryparam value="#ipCity#" cfsqltype="varchar" />,
				ipRegion = <cfqueryparam value="#ipRegion#" cfsqltype="varchar" />,
				ipCountry = <cfqueryparam value="#ipCountry#" cfsqltype="varchar" />,
				createdAt = <cfqueryparam value="#createdAt#" cfsqltype="timestamp" />
		</cfquery>

		<cfreturn val( metaResults.generatedKey ) />

	</cffunction>


	<cffunction name="deleteByFilter" returnType="void">

		<cfargument name="id" type="numeric" required="false" />
		<cfargument name="userID" type="numeric" required="false" />

		<cfset assertIndexPrefix( arguments ) />

		<cfquery name="local.results" result="local.metaResults">
			DELETE FROM
				user_session
			WHERE
				TRUE

			<cfif ! isNull( id )>
				AND
					id = <cfqueryparam value="#id#" cfsqltype="bigint" />
			</cfif>

			<cfif ! isNull( userID )>
				AND
					userID = <cfqueryparam value="#userID#" cfsqltype="bigint" />
			</cfif>
		</cfquery>

	</cffunction>


	<cffunction name="getByFilter" returnType="array">

		<cfargument name="id" type="numeric" required="false" />
		<cfargument name="userID" type="numeric" required="false" />
		<cfargument name="token" type="string" required="false" />
		<cfargument name="withSort" type="string" required="false" default="id" />
		<cfargument name="withLock" type="string" required="false" default="" />

		<cfset assertIndexPrefix( arguments ) />

		<cfquery name="local.results" result="local.metaResults" returnType="array">
			SELECT
				id,
				token,
				userID,
				isAuthenticated,
				ipAddress,
				ipCity,
				ipRegion,
				ipCountry,
				createdAt
			FROM
				user_session
			WHERE
				TRUE

			<cfif ! isNull( id )>
				AND
					id = <cfqueryparam value="#id#" cfsqltype="bigint" />
			</cfif>

			<cfif ! isNull( userID )>
				AND
					userID = <cfqueryparam value="#userID#" cfsqltype="bigint" />
			</cfif>

			<cfif ! isNull( token )>
				AND
					token = <cfqueryparam value="#token#" cfsqltype="varchar" /> COLLATE utf8mb4_bin
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

		<cfreturn decodeColumns( results ) />

	</cffunction>


	<cffunction name="update" returnType="void">

		<cfargument name="id" type="numeric" required="true" />
		<cfargument name="isAuthenticated" type="boolean" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			UPDATE
				user_session
			SET
				isAuthenticated = <cfqueryparam value="#isAuthenticated#" cfsqltype="tinyint" />
			WHERE
				id = <cfqueryparam value="#id#" cfsqltype="bigint" />
		</cfquery>

	</cffunction>

</cfcomponent>
