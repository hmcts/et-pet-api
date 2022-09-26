# ET API

<a href="https://codeclimate.com/github/ministryofjustice/et_api/maintainability"><img src="https://api.codeclimate.com/v1/badges/1229a56ce687e1a1376d/maintainability" /></a>

<a href="https://codeclimate.com/github/ministryofjustice/et_api/test_coverage"><img src="https://api.codeclimate.com/v1/badges/1229a56ce687e1a1376d/test_coverage" /></a>

[![Build Status](https://dev.azure.com/HMCTS-PET/pet-azure-infrastructure/_apis/build/status/et-api?branchName=develop)](https://dev.azure.com/HMCTS-PET/pet-azure-infrastructure/_build/latest?definitionId=17&branchName=develop)

The API server for the ET service including ET1 and ET3

## Introduction

This application is to replace the current JADU system as of March 2018

## API Documentation

API documentation is provided semi automatically using a rake task.  This comes from the
'Rspec API Documentation' gem (https://github.com/zipmark/rspec_api_documentation) which
allows us to define special documentation specs which provide the example data and the
response is recorded and documented for us.

At the moment, we can just use this as it comes out but in the future, it may well be used
as an input to the documentation process if we need more control.

To generate new documentation after you have modified the API in any way, please run

```
rake docs:build
```



and then look in the docs/api folder - you will see open_api.json which is for use with swagger.
You can copy and paste this directly into swaggerhub or use a swagger UI (which hopefully, we will get built
into this app one day so it can be viewed in dev environments)

But, we also have markdown documents which you can just read, see

[docs/api/index.md]

Note: Do not use the rake docs:generate that the gem tells you to - as that will expect things in the wrong place.

## Design

See [this page](docs/design.md)

## Manual Testing

See [this page](docs/manual_testing.md)

## External Dependencies

Unless you are using docker, then you must make sure you have the following dependencies met

### zip and unzip

These are used to produce and test the zip files during exporting of claims

### pdftk

Used to produce PDF's

Note: At the time of writing, this is hanging under OSX - If you are having this issue, please install this version which works

https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/pdftk_server-2.02-mac_osx-10.11-setup.pkg

### mcrypt

Used to decrypt messages from acas

### postgres

Both server, client and nescessary headers for development

### redis

Used for background jobs - not entirely nescessary depending on what you are working on

### azurite

We use microsoft azure wired up to active storage, which you would normally use a test adapter for, however we also have
some code that copies from one container to another which cannot use active storage - so instead, we just use an azure
server (I chose azurite as it has been the most reliable and most feature rich).  See its github page for more
details (https://github.com/Azure/Azurite) - you can install it on OSX and linux - or you can use docker (note that it
is integrated into ./bin/dev/docker-support-services

### Developing And Testing Using The et_full_system gem

Please refer to https://github.com/hmcts/et_full_system_gem for instructions on general use and starting an environment.
Once you have an environment running, read on below ...

#### Developing Locally In Full System

The easiest way to develop is to use the full system to provide everything that you need (database, redis, azurite etc..)
and use a special command to redirect the full system API URL to your local machine.
The command to redirect to your local machine on port 3000 is (note you can use any free port) :-

```
et_full_system docker local_api 3000
```

Then, in this project directory run

```
et_full_system docker api_env > .env
```

which will setup all environment variables to the correct values to work in the full system environment.

then run

```

rails s

```

which will run the web server.  The url is

http://api.et.127.0.0.1.nip.io:3100

### Running support services only

Often, you may want to run the rails server yourself and just have docker bring up 
any supporting services such as the database.

Simply do :-

```

./bin/dev/docker-support-services up

```

which will bring up the database on a random port and a redis server on a random port unless changed by the environment vars.

to kill them (assuming CTRL-C didn't do it)

```

./bin/dev/docker-support-services down

```


As stated above in the 'Running a server section' - you can use 

```

docker ps

```

to find out which ports are being forwarded where.

or if you just want to use a fixed port - then do this :-

```

DB_PORT=5450 ./bin/dev/docker-support-services

```

and use the same DB_PORT when you run your server - so for example with 'rails s' do :-


```

DB_PORT=5450 bundle exec rails s

```

similar with the redis port - but change REDIS_PORT instead - for example

```

REDIS_PORT=6380 ./bin/dev/docker-support-services

```

and use the same port when running the rails server or sidekiq as follows

```

REDIS_PORT=6380 bundle exec rails s

```

and

```

REDIS_PORT=6380 bundle exec sidekiq

```

and the database.yml is configured to read this, therefore the app will use this port instead of the default which is 5432


# Developing And Testing Without Docker

This is just a rails app, so if you want to manage the dependencies etc.. yourself and
setup your own database etc.. Just go about things in the normal way, but remembering these pointers

1. The database.yml uses environment variables so it can be checked into the repository.
   But, these also have defaults so if you have a database running on the standard port on localhost and
   has a user of 'postgres' then you will be good to go.  Otherwise set the environment variables below as you 
   see fit
   DB_HOST
   DB_USERNAME
   DB_PASSWORD
   DB_PORT
   DB_NAME

2. The redis config can be configured using the following to be consistent with
   the database config and also to allow just the port to be overriden (useful for local development)
   REDIS_HOST (defaults to localhost)
   REDIS_PORT (defaults to 6379)
   REDIS_DATABASE (defaults to 1)
   
   You can change any of these individually or you can ignore these by setting the full
   REDIS_URL in the traditional way - such as :-
   
   ```
   
   REDIS_URL=redis://localhost:6379/12
   
   ```

   If your redis server needs a password, it must be specified using

   ```
   REDIS_PASSWORD=<your password>

   ```
   
## With Foreman

Whilst foreman could not be bundled in due to its version of 'thor' being too old at the time
of writing, if you install the foreman gem then you can start all required services for
a production like system using a single command :-

```

foreman start

```
   
If you are doing things manually, remember you may need sidekiq running depending
on what area of the system you are using.   

# Other Environment Variables

## AZURE_STORAGE_BLOB_HOST

This is normally not present - but in test environment, you can set this to "http://localhost:10000" for example to
use the 'azurite' simulator

## AZURE_STORAGE_BLOB_FORCE_PATH_STYLE

This is normally not present - but in test environment, you can set this to 'true' for example to
use the 'azurite' simulator (which must use this value - it doesnt support virtual hosts)

## AZURE_STORAGE_ACCOUNT

In production, this will be the real azure storage account.  In test mode when using 'azurite' simulator, this
must be set to 'devstoreaccount1' as it is hard coded into azurite.

## AZURE_STORAGE_ACCESS_KEY

In production, this will be the real azure storage access key.  In test mode when using 'azurite' simulator, this
must be set to 'Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==' as it is hard coded into azurite.

## AZURE_STORAGE_CONTAINER

This is the storage container name for azure and must conform to microsoft's naming convention which pretty much means
that is must be a valid dns name, must only contain alphanumeric's with '-' separating words - NO underscores or other symbols


## EXPORT_CLAIMS_EVERY

The claims are batched up and zipped ready for consumption by the ATOS API every 15 minutes

If you want to change this during development, set this environment variable - e.g.

```

EXPORT_CLAIMS_EVERY=5

```


will set it to every 5 minutes

# Development Guidelines

The team uses a BDD / TDD approach so it is expected for the specs to be written before the implementation as required.
The use of BDD / TDD should provide us with good test coverage, so a code coverage tool will be used to keep an eye on this.

# API Versioning

## V1 - The Old JADU API

As we need to get the project off the ground very quickly, the V1 API will look and feel
just like the original JADU API - so there are no changes to the ET1 application.

However, this API is very clunky in that it uses XML as part of a multi part form which also sends the files as well.
This can now be done much better using a simple REST interface with base64 encoding of the files as just normal data.

## V2 - The New API For ET3 - and eventually ET1

Version 2 will be written from the ground up for ET3 to begin with, but the long term goal is for ET1 to move over to it so we can remove all of the XML code from ET1 app and just send the data over this RESTful interface.

## The Test Suite

### Database cleaning

In general, it is thought that each test example does not need a perfectly clean database, so at least for now, the database will be partially cleaned when the example
specifies db_clean: true in the example metadata.

A lot of time can get wasted cleaning the database when not required, so it is up to the developer to either write their tests in a way that
does not need a perfectly clean database OR specify that it should be cleaned first using db_clean: true

For example :-

```

RSpec.describe 'Some feature', type: :request do
  it 'should do something with a clean DB to start with', db_clean: true do
    <<code>>
  end
end

```

Note that the strategy at the moment is to clean before a marked example using 'truncation' as opposed to using transactions.

This is because transactions modify the behavior of rails when using postgres. The high level transaction is done one way and the rest are done another - so adding a transaction at the start makes things behave differently.
Also, transactions cannot be used when testing over a real http connection as opposed to rack-test which we may well do.

If on the other hand, we decide the suite is too slow, this may well get changed - but it is much easier to change from truncation to transaction
than the other way around.

### Database test data

Seed data is setup for use in both development and test - containing what is considered to be static data such as offices etc..

### Direct Database Access

There is no admin interface or any way that a 'user' (a user in this case is an API client) can validate that things have been persisted for later use.

Whilst there is an admin project that will connect to the same database as this application, this will not be used during the automated testing of this application.

Instead, we will be going for the direct database approach where the ruby test code can access the same database as the application under test.

# Administering The Database

This application has a partner admin application (https://github.com/ministryofjustice/et-admin) which needs to be setup to share the same database.

The admin is kept separate for scaling purposes as we expect more API users than admin users by a significant factor.

If you just want to do this and nothing else during development and are OK working with ruby - just clone it, set the DB_HOST, DB_NAME, DB_PORT and DB_USERNAME env vars
to point to the same DB as this application and go for it.

If you want to run an entire system including the admin but are not interested in using ruby - i.e. you are testing or just viewing this application, you may want to consider it's "umbrella" project (https://github.com/ministryofjustice/et-full-system)
which used docker-compose to bring all of the components together and allows you to run them much easier.


