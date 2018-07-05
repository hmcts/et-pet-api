FROM ruby:2.3.3-slim
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq5 \
    libpq-dev \
    postgresql-client \
    nodejs \
    npm \
    wget \
    zip \
    net-tools \
    libmcrypt-dev \
    mcrypt
RUN bash -c "wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip && unzip ngrok-stable-linux-amd64.zip -d /bin/"
RUN gem install bundler foreman
RUN mkdir -p /app
WORKDIR /app
CMD /bin/bash -c "tail -f /dev/null"
