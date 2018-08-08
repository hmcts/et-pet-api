#!/bin/bash

echo "Running remote-syslog"

remote_syslog -p 20568 -d logs7.papertrailapp.com --pid-file=/var/run/remote_syslog.pid --hostname=$PAPERTRAIL_NAME /usr/src/app/log/production.log

bundle exec sidekiq -C config/sidekiq.yml
