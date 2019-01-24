#!/bin/bash
echo "printing"
CURRENT_BUILD_NO =  expr $BUILD_NO - 1
echo $CURRENT_BUILD_NO
cd /home/ubuntu/circleci-poc && wget https://$CURRENT_BUILD_NO-166982537-gh.circle-artifacts.com/0/root/project/own-artifact && unzip own_artifact.zip
source ~/.bash_profile;
kill -9 $(lsof -i tcp:3000 -t)
echo 'Benchmarking $(pwd)...'
cd /home/ubuntu/circleci-poc/usr/src/app && bundle install && rails s -b 0.0.0.0 -d

