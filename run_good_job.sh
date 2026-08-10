#!/bin/bash

exec env WEB_CONCURRENCY=0 bundle exec good_job start --probe-port=${PORT:-8080}
