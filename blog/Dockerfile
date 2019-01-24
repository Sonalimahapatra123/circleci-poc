FROM ruby:2.5
RUN apt-get update -yqq
COPY . /usr/src/app/
COPY Gemfile* /usr/src/app/
WORKDIR /usr/src/app
RUN bundle install
