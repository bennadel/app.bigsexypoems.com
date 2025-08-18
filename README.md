
# app.bigsexypoems.com

by [Ben Nadel][ben-nadel]

This is the logged-in experience for Big Sexy Poems. Historically, the poem editor has been a client-only, proof-of-concept (PoC) application hosted on Netlify. I'm trying to transition that to a **ColdFusion** application in which the poems can be saved and shared using persisted data.


## Installing `node` Modules

This is, by far, the jankiest part of this whole experiment. Since I'm using Docker to manage the `node_modules` folder, I can't "just" `npm install` new dependencies. Instead, I have to "bash into" a running `client` container and then invoke the `npm install --save-dev` from within the container context.

To do this:

* Make sure neither `client` nor `client-dev` container are running.
* Execute `docker compose run --rm client sh`.
* Execute `npm` commands to modify the `package*.json` files.
* Execute `exit` to quit and remove the temporary container.

Since the `package.json` and `package-lock.json` files are mounted via Docker volumes, the `npm install` commands, executed from within the running container, should propagate changes back to the host files.


[ben-nadel]: https://www.bennadel.com/
