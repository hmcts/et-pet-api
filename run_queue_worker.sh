#!/bin/bash

until bundle exec rails db:abort_if_pending_migrations; do
  echo "Waiting for databases and migrations..."
  sleep 5
done

exec bundle exec good_job start --probe-port="${PORT:-8080}" "$@"
