# Design

## Systems Level

The entire system consists of 4 components, at the time of writing all separate rails applications.

These are :-

* The API (This system)
* The admin (https://github.com/ministryofjustice/et-admin)
* ET1 (https://github.com/ministryofjustice/atet)
* ET3 https://github.com/ministryofjustice/et3

The admin and API share the same database and redis instance and are kept in separate apps for
scaling reasons.  The admin is quite a big app with all of the 'activeadmin' stuff etc.. and the
API is a rails 'api mode' app - so far less dependencies and much much less memory usage - allowing
it to be scaled higher on a single box.
We will not have much admin traffic so pointless scaling it to the same level as the API


To assist in development and automated testing only, an 'umbrella project' exists (https://github.com/ministryofjustice/et-full-system)
which brings all four of these components together using git submodules (for now) and docker-compose.
It allows you to start up all servers with one command, share (using docker port forwarding) various services including the database, redis and the http servers
of the individual apps themselves.

If you are running automated tests you wont need to share anything (unless developing the tests where it might be useful for speed) - there is a command to
run any command on the docker instance - so you can do your normal stuff such as 'rspec', 'cucumber' etc..

Please visit the repo above for more details about this

## This System

This system is a fairly standard rails application with the following additions / modifications

* Service Objects - To keep the interface to a 'domain' nice and easy to use from anywhere - whether its a controller, a test, a model - functionality is wrapped in service objects - even for simpler things. This keeps our HTTP layer (i.e. the controllers)
  more like an interface to existing code rather than having functionality inside the controllers.
* No Active Job - As a team we decided not to use active job, but go for sidekiq directly.  This is for many reasons including configurability, availability of plugins and performance.
* Active Storage - New to Rails 5.2 (which we are using here in the hope it will be released properly ready for go live) - replaces carrierwave and is configure for Amazon S3 (production) and local file systems (other environments)
* Docker Support - Whilst we would never insist anyone uses docker for development / test etc.. it is certainly very handy so some scripts inside the bin/dev folder assist with running things inside the docker-compose setup provided.
* Highly Configurable - From the database to the capybara setup - anything where 1 developer is likely to want things slightly different to another is configurable using environment variables (with sensible defaults).  This makes running in different docker environments much easier
  and allows developers to run multiple instances of things whilst being in control of ports etc.. without having to change source code and remembering not to commit the change !!
* SQL based schema - You might notice that we don't have a schema.db - but instead an SQL version.  This is because the ruby representation of the schema doesn't allow
  us to do everything that SQL does.  In this case, something as simple as making sure a sequence starts from a set number (so reference numbers start at 20000000)
* Vendored Gem - A separate gem has been developed for the ATOS interface as it is ugly and I didn't want that code in the main app.  Another reason is that dev-ops might
  choose to deploy this app separately (at the moment, it is mounted in the main app's routes) as it is exposed to the outside world which is a
  third party system.  Deploying separately means the attack surface is much smaller from a security point of view.



