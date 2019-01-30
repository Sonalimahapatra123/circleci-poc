#!/bin/bash
echo "printing"
CURRENT_BUILD_NO=$(expr $BUILD_NO - 1)
echo $CURRENT_BUILD_NO
cd /home/ubuntu/circleci-poc
rm -rf *
wget https://$CURRENT_BUILD_NO-166982537-gh.circle-artifacts.com/0/root/project/own-artifact && unzip own-artifact
cd /home/ubuntu/circleci-poc/usr/src/app
sudo docker rmi -f madhantry/mdn-images:latest
sudo docker pull madhantry/mdn-images:latest && sudo docker-compose rm && sudo docker-compose up -d




