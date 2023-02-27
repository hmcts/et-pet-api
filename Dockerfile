FROM ruby:2.7.7-alpine

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
COPY --from=clevyr/pdftk-java /app/ /usr/local/bin/
RUN ln -s /opt/java/openjdk-trimmed/bin/java /usr/local/bin/java
RUN chown -R app:app /usr/local/bundle
RUN apk add --no-cache runit unzip zip libmcrypt-dev libpq-dev tzdata gettext shared-mime-info libc6-compat bash file && \
    apk add --no-cache postgresql-client~=11.12 --repository=http://dl-cdn.alpinelinux.org/alpine/v3.10/main && \
    apk add --no-cache --virtual .build-tools git build-base openjdk11 && \
    jlink --add-modules java.base,java.desktop,java.naming,java.sql --strip-debug --no-man-pages --no-header-files --compress=2 --output=/opt/java/openjdk-trimmed && \
    cd /home/app/api && \
    gem install bundler -v 1.17.3 && \
    bundle install --no-cache --jobs=5 --retry=3 --without=test development --with=production --deployment && \
    apk del .build-tools && \
    chown -R app:app /usr/local/bundle && \
    mkdir -p /home/app/api/tmp && \
    chown -R app:app /home/app/api/tmp


USER app
ENV HOME /home/app
WORKDIR /home/app/api
ENV RAILS_ENV=production
CMD ["bundle", "exec", "iodine", "-port", "8080"]
