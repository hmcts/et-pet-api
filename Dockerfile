FROM employmenttribunal.azurecr.io/ruby26-onbuild:0.1

# Adding argument support for ping.json
ARG APPVERSION=unknown
ARG APP_BUILD_DATE=unknown
ARG APP_GIT_COMMIT=unknown
ARG APP_BUILD_TAG=unknown

# Setting up ping.json variables
ENV APPVERSION ${APPVERSION}
ENV APP_BUILD_DATE ${APP_BUILD_DATE}
ENV APP_GIT_COMMIT ${APP_GIT_COMMIT}
ENV APP_BUILD_TAG ${APP_BUILD_TAG}

# add official nodejs repo
# RUN curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
#         echo 'deb https://deb.nodesource.com/node jessie main' > /etc/apt/sources.list.d/nodesource.list

# install runit, nodejs and pdftk
# RUN apt-get update && apt-get install -y runit nodejs pdftk unzip zip mcrypt libmcrypt-dev && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/* && rm -fr *Release* *Sources* *Packages* && \
#     truncate -s 0 /var/log/*log

EXPOSE 8080

