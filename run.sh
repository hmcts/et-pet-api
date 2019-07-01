#!/bin/bash

case ${DOCKER_STATE} in
migrate)
    echo "Running migrate"
    bundle exec rake db:migrate
    ;;
create)
    echo "Running create"
    bundle exec rake db:create
    bundle exec rake db:migrate
    bundle exec rake db:seed
    ;;
esac
cd /home/app/
bundle exec puma --port=${PORT:-8080} --config=./config/puma.rb --environment=${RAILS_ENV:-production}
