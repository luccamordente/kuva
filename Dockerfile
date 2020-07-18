FROM ruby:2.2

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get install -y nodejs ruby-dev libmagickwand-dev imagemagick

WORKDIR /app