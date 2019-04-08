#!/bin/bash
shopt -s extglob
set -e
# rm -rf circleci-poc-unicorn && rm -rf circleci-poc-sidekiq && rm -rf circleci-poc-cron
cp -r $CODEBUILD_SRC_DIR/blog circleci-poc-unicorn

# For unicorn
cd circleci-poc-unicorn && rm -rf Gemfile Gemfile.lock vendor/* gemfile_for_sidekiq gemfile_for_cron
mv gemfile_for_unicorn Gemfile
bundle package && bundle install --local

cd ../
#For sidekiq related files 
cd circleci-poc-sidekiq && rm -rf Gemfile Gemfile.lock vendor/* gemfile_for_unicorn gemfile_for_cron
mv gemfile_for_sidekiq Gemfile
cd app && rm -rf !(workers|models)
cd ../
rm -rf !(bin|app|Gemfile|config|db|log|scripts|vendor)
echo "gem file content "
echo $(cat Gemfile)
bundle package && bundle install --local #&& bundle exec sidekiq -d -L log/sidekiq.log
