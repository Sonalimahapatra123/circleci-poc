FROM ruby:2.3-slim
RUN apt-get update -yqq
RUN apt-get install -y build-essential patch ruby-dev zlib1g-dev liblzma-dev default-libmysqlclient-dev
RUN apt-get install -y zip
COPY . /usr/src/app/
COPY Gemfile* /usr/src/app/
WORKDIR /usr/src/app
RUN bundle install
