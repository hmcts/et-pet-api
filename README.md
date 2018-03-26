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

./bin/dev/docker-server

```

which will run a server on port 3000

or if port 3000 is in use or you just want to use a different port

```

PORT=3200 ./bin/dev/docker-server

```

which will run a server on port 3200

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

which will bring up the database on port 5432

or if you already have a postgres server on your machine running on that port but still want to
use the docker one to keep yours tidy - then you use a different port like this :-

```

DB_PORT=5450 ./bin/dev/docker-support-services

```

and use the same DB_PORT when you run your server - so for example with 'rails s' do :-


```

DB_PORT=5450 rails s

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
   
   