#!/bin/bash

exec bundle exec good_job start --probe-port="${PORT:-8080}" "$@"
