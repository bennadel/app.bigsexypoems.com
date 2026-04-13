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
		<cfargument name="token" type="string" required="true" />
		<cfargument name="name" type="string" required="true" />
		<cfargument name="noteMarkdown" type="string" required="true" />
		<cfargument name="noteHtml" type="string" required="true" />
		<cfargument name="isSnapshot" type="boolean" required="true" />
		<cfargument name="snapshotName" type="string" required="true" />
		<cfargument name="snapshotContent" type="string" required="true" />
		<cfargument name="viewingCount" type="numeric" required="true" />
		<cfargument name="lastViewingAt" type="any" required="true" />
		<cfargument name="createdAt" type="date" required="true" />
		<cfargument name="updatedAt" type="date" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			INSERT INTO
				poem_share
			SET
				poemID = <cfqueryparam value="#poemID#" cfsqltype="bigint" />,
				token = <cfqueryparam value="#token#" cfsqltype="varchar" />,
				name = <cfqueryparam value="#name#" cfsqltype="varchar" />,
				noteMarkdown = <cfqueryparam value="#noteMarkdown#" cfsqltype="longvarchar" />,
				noteHtml = <cfqueryparam value="#noteHtml#" cfsqltype="longvarchar" />,
				isSnapshot = <cfqueryparam value="#isSnapshot#" cfsqltype="tinyint" />,
				snapshotName = <cfqueryparam value="#snapshotName#" cfsqltype="varchar" />,
				snapshotContent = <cfqueryparam value="#snapshotContent#" cfsqltype="varchar" />,
				viewingCount = <cfqueryparam value="#viewingCount#" cfsqltype="bigint" />,
				lastViewingAt = <cfqueryparam value="#lastViewingAt#" null="#isNotDate( lastViewingAt )#" cfsqltype="timestamp" />,
				createdAt = <cfqueryparam value="#createdAt#" cfsqltype="timestamp" />,
				updatedAt = <cfqueryparam value="#updatedAt#" cfsqltype="timestamp" />
		</cfquery>

		<cfreturn val( metaResults.generatedKey ) />

	</cffunction>


	<cffunction name="deleteByFilter" returnType="void">

		<cfargument name="id" type="numeric" required="false" />
		<cfargument name="poemID" type="numeric" required="false" />

		<cfset assertIndexPrefix( arguments ) />

		<cfquery name="local.results" result="local.metaResults">
			DELETE FROM
				poem_share
			WHERE
				TRUE

			<cfif ! isNull( id )>
				AND
					id = <cfqueryparam value="#id#" cfsqltype="bigint" />
			</cfif>

			<cfif ! isNull( poemID )>
				AND
					poemID = <cfqueryparam value="#poemID#" cfsqltype="bigint" />
			</cfif>
		</cfquery>

	</cffunction>


	<cffunction name="getByFilter" returnType="array">

		<cfargument name="id" type="numeric" required="false" />
		<cfargument name="poemID" type="numeric" required="false" />
		<cfargument name="token" type="string" required="false" />
		<cfargument name="withSort" type="string" required="false" default="id" />
		<cfargument name="withLock" type="string" required="false" default="" />

		<cfset assertIndexPrefix( arguments ) />

		<cfquery name="local.results" result="local.metaResults" returnType="array">
			SELECT
				id,
				poemID,
				token,
				name,
				noteMarkdown,
				noteHtml,
				isSnapshot,
				snapshotName,
				snapshotContent,
				viewingCount,
				lastViewingAt,
				createdAt,
				updatedAt
			FROM
				poem_share
			WHERE
				TRUE

			<cfif ! isNull( id )>
				AND
					id = <cfqueryparam value="#id#" cfsqltype="bigint" />
			</cfif>

			<cfif ! isNull( poemID )>
				AND
					poemID = <cfqueryparam value="#poemID#" cfsqltype="bigint" />
			</cfif>

			<cfif ! isNull( token )>
				AND
					token = <cfqueryparam value="#token#" cfsqltype="string" /> COLLATE utf8mb4_bin
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
		<cfargument name="noteMarkdown" type="string" required="true" />
		<cfargument name="noteHtml" type="string" required="true" />
		<cfargument name="isSnapshot" type="boolean" required="true" />
		<cfargument name="snapshotName" type="string" required="true" />
		<cfargument name="snapshotContent" type="string" required="true" />
		<cfargument name="viewingCount" type="numeric" required="true" />
		<cfargument name="lastViewingAt" type="any" required="true" />
		<cfargument name="updatedAt" type="date" required="true" />

		<cfquery name="local.results" result="local.metaResults">
			UPDATE
				poem_share
			SET
				name = <cfqueryparam value="#name#" cfsqltype="varchar" />,
				noteMarkdown = <cfqueryparam value="#noteMarkdown#" cfsqltype="longvarchar" />,
				noteHtml = <cfqueryparam value="#noteHtml#" cfsqltype="longvarchar" />,
				isSnapshot = <cfqueryparam value="#isSnapshot#" cfsqltype="tinyint" />,
				snapshotName = <cfqueryparam value="#snapshotName#" cfsqltype="varchar" />,
				snapshotContent = <cfqueryparam value="#snapshotContent#" cfsqltype="varchar" />,
				viewingCount = <cfqueryparam value="#viewingCount#" cfsqltype="bigint" />,
				lastViewingAt = <cfqueryparam value="#lastViewingAt#" null="#isNotDate( lastViewingAt )#" cfsqltype="timestamp" />,
				updatedAt = <cfqueryparam value="#updatedAt#" cfsqltype="timestamp" />
			WHERE
				id = <cfqueryparam value="#id#" cfsqltype="bigint" />
		</cfquery>

	</cffunction>

</cfcomponent>
