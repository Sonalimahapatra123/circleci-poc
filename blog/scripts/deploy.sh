#!/bin/bash
echo "printing"
CURRENT_BUILD_NO=$(expr $BUILD_NO - 1)
echo $CURRENT_BUILD_NO
cd /home/ubuntu/circleci-poc
rm -rf *
wget https://$CURRENT_BUILD_NO-166982537-gh.circle-artifacts.com/0/root/project/own-artifact && unzip own-artifact
# source ~/.bash_profile;
# kill -9 $(lsof -i tcp:3000 -t)
# echo 'Benchmarking $(pwd)...'
cd /home/ubuntu/circleci-poc/usr/src/app
sudo docker-compose down
sudo docker rmi -f madhantry/mdn-images:latest
sudo docker pull madhantry/mdn-images:latest && docker-compose run web rake db:create && docker-compose up -d
#sudo docker-compose up -d
# bundle install && rails s -b 0.0.0.0 -d



