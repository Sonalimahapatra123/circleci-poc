#!/bin/bash
echo $CIRCLE_BUILD_NUM
cd ~/circleci-poc && rm -rf usr/ && rm own_artifact.zip && wget https://${CIRCLE_BUILD_NUM}-166982537-gh.circle-artifacts.com/0/root/project/own-artifact/own_artifact.zip && unzip own_artifact.zip
source ~/.bash_profile;
kill -9 $(lsof -i tcp:3000 -t)
echo 'Benchmarking $(pwd)...'
cd ~/circleci-poc/usr/src/app && bundle install && rails s -b 0.0.0.0 -d

