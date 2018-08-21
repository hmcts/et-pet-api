#!/bin/bash

./expand_variables.sh
python ./awslogs-agent-setup.py -n -r eu-west-1 -c ./awslogs.conf

bundle exec sidekiq -C config/sidekiq.yml
