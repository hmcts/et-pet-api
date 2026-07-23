#!/bin/bash

case ${DOCKER_STATE} in
migrate)
    echo "Preparing databases"
    bundle exec rails db:prepare
    ;;
create)
    echo "Running create"
    bundle exec rake db:create
    bundle exec rake db:migrate
    bundle exec rake db:seed
    ;;
esac

exec bin/rails server --binding 0.0.0.0 --port "${PORT:-8080}"
