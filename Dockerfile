FROM ministryofjustice/ruby:2.5.1

# Adding argument support for ping.json
ARG APPVERSION=unknowntc
ARG APP_BUILD_DATE=unknowntc
ARG APP_GIT_COMMIT=unknowntc
ARG APP_BUILD_TAG=unknowntc

# Setting up ping.json variables
ENV APPVERSION ${APPVERSION}
ENV APP_BUILD_DATE ${APP_BUILD_DATE}
ENV APP_GIT_COMMIT ${APP_GIT_COMMIT}
ENV APP_BUILD_TAG ${APP_BUILD_TAG}

# Ensure the pdftk package is installed as a prereq for ruby PDF generation
ENV DEBIAN_FRONTEND noninteractive

# SSH proxy settings
ENV SSH_AUTH_SOCK /tmp/ssh-auth
ENV SSH_AUTH_PROXY_PORT 1234

# add official nodejs repo
RUN curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
        echo 'deb https://deb.nodesource.com/node jessie main' > /etc/apt/sources.list.d/nodesource.list

# install runit, nodejs and pdftk
RUN apt-get update && apt-get install -y runit nodejs pdftk unzip zip mcrypt libmcrypt-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && rm -fr *Release* *Sources* *Packages* && \
    truncate -s 0 /var/log/*log

RUN mkdir -p /usr/src/app
RUN bundle config --global without test:development
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

# There are local gems in the vendor folder which need to be copied before run bundle install
COPY ./vendor /usr/src/app/vendor

# Hack to install private gems
RUN socat UNIX-LISTEN:$SSH_AUTH_SOCK,fork TCP4:$(ip route|awk '/default/ {print $3}'):$SSH_AUTH_PROXY_PORT & bundle install

RUN curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
RUN mkdir /etc/cron.d
RUN touch /etc/cron.d/awslogs
RUN apt-get update
RUN apt-get -y install supervisor
RUN mkdir -p /var/log/supervisor
RUN mkdir -p /etc/supervisor/conf.d/
COPY supervisor_awslogs.conf /etc/supervisor/conf.d/
COPY supervisor.conf /etc/supervisor.conf

COPY . /usr/src/app

EXPOSE 8080

CMD ["./run.sh"]
