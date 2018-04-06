# ET API

Experiment - DO NOT USE

## Introduction

At the moment, this is an exploratory application that will replace the
JADU system.

## Developing And Testing Using Docker

### Initial Setup (Run once)

```
    ./bin/dev/docker ./bin/setup
```

### Running a server

```

./bin/dev/docker-server up

```


which will run a server on a randomly assigned port which is great if you don't want to do
port forwarding (e.g. running automated tests doesnt rely on it - its just for traditional
manual browser based testing).

If you want to find out what this port is, just use 

```

docker ps

```

and look for something like this

```

CONTAINER ID        IMAGE               COMMAND                  CREATED                  STATUS                  PORTS                     NAMES
ffefd71a2b99        dev_dev             "irb"                    Less than a second ago   Up Less than a second   0.0.0.0:32770->8080/tcp   dev_dev_1
c8bd276535aa        postgres:9.3.5      "/docker-entrypoint.…"   Less than a second ago   Up 1 second             0.0.0.0:32769->5432/tcp   dev_db_1
854adc82aba2        redis               "docker-entrypoint.s…"   3 minutes ago            Up 3 minutes            0.0.0.0:32768->6379/tcp   dev_redis_1


```

where it can be seen that the 'dev' process is forwarding port 32770 to
port 8080 in the docker container, allowing you to go to http://localhost:32770 on your 
machine (depending if you need to setup yet another port forward if you are using a version
of docker that doesnt forward straight to your localhost)

or if you want to specify the port - lets say you just want it on port 3000 and have ensured
that it is available - else it wont start.

```

PORT=3200 ./bin/dev/docker-server

```

which will run a server on port 3200


### Killing The Server

Sometimes you need to do this - if CTRL-C seems to stop really quickly !!

```

./bin/dev/docker-server down

```

### Running commands on the docker box

If you want to connect to the same machine to run other commands whilst the server is running :-


```

./bin/dev/docker-exec bash

```

which will give you a bash session

or you can run other commands - for example

```

./bin/dev/docker-exec bundle exec rails c

```


will give you a rails console



### Running support services only

Often, you may want to run the rails server yourself and just have docker bring up 
any supporting services such as the database.

Simply do :-

```

./bin/dev/docker-support-services

```

which will bring up the database on a random port and a redis server on a random port.

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
   
## With Foreman

Whilst foreman could not be bundled in due to its version of 'thor' being too old at the time
of writing, if you install the foreman gem then you can start all required services for
a production like system using a single command :-

```

foreman start

```
   
If you are doing things manually, remember you may need sidekiq running depending
on what area of the system you are using.   
   