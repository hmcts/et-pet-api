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

./expand_variables.sh
python ./awslogs-agent-setup.py -n -r eu-west-1 -c ./awslogs.conf
ps -eaf | grep awslogs | grep -v grep | awk -F' ' '{print $2'} | xargs kill -9
supervisord -c /etc/supervisor.conf &

echo "Running app"

bundle exec puma --port=8080 --config=./config/puma.rb --environment=production
