
# Poem Revisions

This document outlines the way we want to render revisions within the application and the way we want to allow revisions to be selected and copied into the current poem. The following are assertions about the way revisions should work within the application.

* On the poem detail page, there should be a link in the sub-navigation to the list of revisions.

* The list of revisions can probably be accessed using the revision model. Meaning we don't need a specialized view controller gateway.

* The list of revisions should contain the date that the revision was created and a preview of the poem.

* The date should be a link that brings you to the revision detail page.

* The detail page should show a diff of the poem using the existing poem diff module. The original content for the diff should be the given revision and the modified version of the diff should be the live poem. So the detail page always shows the difference between the current revision and the live poem.

* The detail page should have a link to go to the previous revision and a link to go to the next revision in the sequential list.

* The detail page should have a form button that selects the current revision as as the live poem content, meaning a button that copies the current revision onto the stack of revisions and replaces the poem content. 

* A `RevisionAccess.cfc` has to be created to assert permissions. It should mirror the `ShareAccess.cfc` - if you can access the poem, you can access the revision.

* A `RevisionService.cfc` has to be created to allow a revision to be "made current". Making a revision current means that we copy the given revision's name and content into the live poem, and we create a new revision. for that state. The new revision should always be created regardless of the 120-second revision window logic that already exists on the application. Meaning when you make an old revision current, it's an absolute request, not a fuzzy request.

* I don't think we need any specialized partial gateways. I think that all of the data, at least for the time being, can be accessed through the model. For the revision detail page we can access the current revision through the revision access CFC and then we can also get a list of all the revisions by filtering down on the poem ID. It's not super efficient, but it'll work.

