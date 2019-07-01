#!/bin/bash
cd /home/app/
bundle exec sidekiq -C config/sidekiq.yml
