
# app.bigsexypoems.com

by [Ben Nadel][ben-nadel]


## Overview

This is a codification of my **BigSexyPoems** concept. Historically, the poem editor was a static, Angular-based proof-of-concept (PoC) application hosted on Netlify. I'm trying to transition that to a **ColdFusion**, **HTMX**, and **AlpineJS** application in which the poems can be saved and shared using persisted data.

Mostly, I just want a real-world application in which I can experiment with ideas and try out new paradigms for organizing my code.

Try it out for yourself: _\[login coming soon\]_


## Docker Setup

The application runs locally using Docker. To run BigSexyPoems, simply run `docker compose up` from this directory. The application expects you to have an entry in your `etc/hosts` file for the local domain:

```hosts
127.0.0.1	app.local.bigsexypoems.com
```

Under the hood, I'm using the base [CommandBox image][commandbox-image], which will download the desired version of ColdFusion at start-up. As such, the start-up time can take 2-3 minutes for the `cfml` container.

> **Aside**: there's a way to optimize / finalize this, but I'm still very much a beginner when it comes to CommandBox.

The CommandBox image provides an "untrusted" SSL certificate in order to enable `https` locally. The first time you access `https://app.local.bigsexypoems.com`, you will need to _accept_ the SSL certificate - in the browser UI - in order to proceed to the site.


## Local SMTP Server

I'm using the [MailHog image][mailhog-image].

Web interface: http://app.local.bigsexypoems.com:8025/


## Local MySQL Database

I'm using the [MySql image][mysql-image].


## Client-Side Development

I'm using the following vendors for my client-side interactivity and styling:

* [Alpine.js][alpinejs] - light-weight JavaScript framework.
* [htmx][htmx] - AJAX-based extensions for HTML.
* [LessCSS][lesscss] - CSS pre-processor.
* [Parcel][parcel] - build tool for client assets.


## Installing `node` Modules

This is, by far, the jankiest part of this whole experiment. Since I'm using Docker to manage the `node_modules` folder, I can't "just" `npm install` new dependencies. Instead, I have to "bash into" a running `client` container and then invoke the `npm install --save-dev` from within the container context.

To do this:

* Make sure neither `client` nor `client-dev` container are running.
* Execute `docker compose run --rm client sh`.
* Execute `npm` commands to modify the `package*.json` files.
* Execute `exit` to quit and remove the temporary container.

Since the `package.json` and `package-lock.json` files are mounted via Docker volumes, the `npm install` commands, executed from within the running container, should propagate changes back to the host files.


[alpinejs]: https://alpinejs.dev/

[ben-nadel]: https://www.bennadel.com/

[commandbox-image]: https://hub.docker.com/r/ortussolutions/commandbox/

[htmx]: https://htmx.org/

[lesscss]: https://lesscss.org/

[mailhog-image]: https://hub.docker.com/r/mailhog/mailhog/

[mysql-image]: https://hub.docker.com/_/mysql

[parcel]: https://parceljs.org/
