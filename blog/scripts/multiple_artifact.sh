#!/bin/bash
shopt -s extglob
rm -rf circleci-poc-unicorn && rm -rf circleci-poc-sidekiq && rm -rf circleci-poc-cron
#cp -vr circleci-poc/blog circleci-poc-unicorn
cp -vr circleci-poc/blog circleci-poc-sidekiq
#cp -vr circleci-poc/blog circleci-poc-cron


cd circleci-poc-sidekiq && rm -rf Gemfile Gemfile.lock vendor/* gemfile_for_unicorn gemfile_for_cron
mv gemfile_for_sidekiq Gemfile

#sidekiq related files to delete
cd app && rm -rf !(workers|models)
cd ../
rm -rf !(bin|app|Gemfile|config|db|log|scripts|vendor)
bundle package && bundle install --local && bundle exec sidekiq -d -L log/sidekiq.log


#For cron
# cd circleci-poc-cron && rm -rf Gemfile Gemfile.lock vendor/* gemfile_for_unicorn gemfile_for_sidekiq
# mv gemfile_for_cron Gemfile

# # sidekiq related files to delete
# cd app && rm -rf !(models)
# cd ../
# echo $(pwd)
# rm -r config/initializers
# cd config && rm -rf !(environments|application.rb|boot.rb|schedule.rb|database.yml|environment.rb)
# cd ../
# echo $(ls)
# rm -rf !(bin|app|Gemfile|config|db|log|scripts|vendor|lib|Rakefile)
# bundle package && bundle install --local && whenever --update-crontab --set environment=development
