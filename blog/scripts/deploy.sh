#!/bin/bash
echo "printing"
echo $BUILD_NO
cd ~/circleci-poc && wget https://$BUILD_NO-166982537-gh.circle-artifacts.com/0/root/project/own-artifact/own_artifact.zip && unzip own_artifact.zip
# source ~/.bash_profile;
# kill -9 $(lsof -i tcp:3000 -t)
# echo 'Benchmarking $(pwd)...'
#cd ~/circleci-poc/usr/src/app && bundle install && rails s -b 0.0.0.0 -d

