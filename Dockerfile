FROM ruby:3.3.5-alpine

RUN addgroup app --gid 1000
RUN adduser -SD -u 1000 --shell /bin/bash --home /home/app app app


ARG APPVERSION=unknown
ARG APP_BUILD_DATE=unknown
ARG APP_GIT_COMMIT=unknown
ARG APP_BUILD_TAG=unknown

# Setting up ping.json variables
ENV APPVERSION ${APPVERSION}
ENV APP_BUILD_DATE ${APP_BUILD_DATE}
ENV APP_GIT_COMMIT ${APP_GIT_COMMIT}
ENV APP_BUILD_TAG ${APP_BUILD_TAG}

EXPOSE 8080

COPY --chown=app:app . /home/app/api
COPY --from=pdftk/pdftk /usr/bin/pdftk /usr/local/bin/pdftk
COPY --from=pdftk/pdftk /usr/share/java/bcprov.jar /usr/share/java/bcprov.jar
COPY --from=pdftk/pdftk /usr/share/java/commons-lang3.jar /usr/share/java/commons-lang3.jar
COPY --from=pdftk/pdftk /usr/share/java/pdftk.jar /usr/share/java/pdftk.jar
RUN chown -R app:app /usr/local/bundle
RUN apk add --no-cache runit unzip zip libmcrypt-dev libpq-dev tzdata gettext shared-mime-info libc6-compat bash file msttcorefonts-installer openjdk8-jre \
    ttf-freefont ttf-opensans ttf-inconsolata \
    ttf-liberation ttf-dejavu && \
    apk add --no-cache postgresql-client~=11.12 --repository=http://dl-cdn.alpinelinux.org/alpine/v3.10/main && \
    apk add --no-cache --virtual .build-tools git build-base && \
    cd /home/app/api && \
    BUNDLER_VERSION=$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1 | awk '{$1=$1};1') && \
    gem install bundler:$BUNDLER_VERSION invoker && \
    bundle config set without 'test development' && \
    bundle config set deployment 'true' && \
    bundle config set with 'production' && \
    bundle install --no-cache --jobs=5 --retry=3 && \
    apk del .build-tools && \
    chown -R app:app /usr/local/bundle && \
    chown -R app:app /home/app/api/vendor/bundle && \
    mkdir -p /home/app/api/tmp && \
    chown -R app:app /home/app/api/tmp

USER app
ENV HOME /home/app
WORKDIR /home/app/api
ENV RAILS_ENV=production
CMD ["bundle", "exec", "rails", "server:start"]
