#!/bin/bash
shopt -s extglob
set -e
# rm -rf circleci-poc-unicorn && rm -rf circleci-poc-sidekiq && rm -rf circleci-poc-cron
cp -r $CODEBUILD_SRC_DIR/blog circleci-poc-cron

#For cron
cd circleci-poc-cron && rm -rf Gemfile Gemfile.lock vendor/* gemfile_for_unicorn gemfile_for_sidekiq
mv gemfile_for_cron Gemfile

# sidekiq related files to delete
cd app && rm -rf !(models)
cd ../
rm -r config/initializers
cd config && rm -rf !(environments|application.rb|boot.rb|schedule.rb|database.yml|environment.rb)
cd ../
rm -rf !(bin|app|Gemfile|config|db|log|scripts|vendor|lib|Rakefile)
echo "cron gem file"
echo $(cat Gemfile)
echo $(pwd)
echo $(ls)
bundle package && bundle install --gemfile Gemfile #&& whenever --update-crontab --set environment=development
exit 0
