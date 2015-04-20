FROM ruby:2.1.5
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# Install RMagick
RUN apt-get install -y libmagickwand-dev imagemagick

RUN mkdir /myapp
WORKDIR /tmp
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install -j 4

ADD . /myapp
WORKDIR /myapp
