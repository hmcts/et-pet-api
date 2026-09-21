#!/bin/bash

case ${DOCKER_STATE} in
migrate)
    echo "Running migrate"
    bundle exec rake db:migrate:with_data
    ;;
create)
    echo "Running create"
    bundle exec rake db:create
    bundle exec rake db:migrate:with_data
    bundle exec rake db:seed
    ;;
esac

bundle exec puma -p ${PORT:-8080}
