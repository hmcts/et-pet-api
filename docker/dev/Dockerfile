FROM ruby:2.5-slim
# Set correct environment variables.
ENV HOME /root

RUN useradd -m app && echo "app:app" | chpasswd && adduser app sudo

CMD /bin/bash -c "tail -f /dev/null"

RUN gem update --system

# ...put your own build instructions here...
RUN apt-get update && apt-get -y --no-install-recommends install libpq-dev build-essential patch ruby-dev zlib1g-dev liblzma-dev git nodejs npm pdftk tzdata postgresql gettext-base wget sudo libmcrypt-dev mcrypt sqlite3 libsqlite3-dev && rm -rf /var/lib/apt/lists/*

# Install forego (for Procfile running)
RUN bash -lc "wget https://bin.equinox.io/c/ekMN3bCZFUn/forego-stable-linux-amd64.deb && apt install ./forego-stable-linux-amd64.deb && rm ./forego-stable-linux-amd64.deb"

# Install azurite
RUN bash -lc "npm install -g azurite@2.7.0"

# Create the azure_storage_data directory for the azure storage server
RUN mkdir -p /home/app/azure_storage_data; chown app:app /home/app/azure_storage_data; chmod 0777 /home/app/azure_storage_data

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /home/app/et-api; chown app:app /home/app/et-api

RUN usermod -o -u 1000 app
RUN groupmod -o -g 1000 app
WORKDIR /home/app/et-api
RUN echo "app ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/user && chmod 0440 /etc/sudoers.d/user
USER app

WORKDIR /home/app/et-api

RUN cd /home/app
ENV HOME /home/app
