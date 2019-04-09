#!/bin/bash
shopt -s extglob
set -e
# rm -rf circleci-poc-unicorn && rm -rf circleci-poc-sidekiq && rm -rf circleci-poc-cron
cp -r $CODEBUILD_SRC_DIR/blog circleci-poc-sidekiq

#For sidekiq related files
echo "list of files"
 
cd circleci-poc-sidekiq
echo $(ls)
rm -rf Gemfile Gemfile.lock vendor/* gemfile_for_unicorn gemfile_for_cron
echo "after removal"
echo $(ls)
#mv gemfile_for_sidekiq Gemfile
cd app && rm -rf !(workers|models)
cd ../
rm -rf !(bin|app|Gemfile|config|db|log|scripts|vendor|gemfile_for_sidekiq)
echo "gem file content "
echo "current direc tory"
echo $(pwd)
echo $(cat gemfile_for_sidekiq)
echo $(pwd)
echo "form current"
echo $(ls)
bundle package && bundle install --gemfile gemfile_for_sidekiq #&& bundle exec sidekiq -d -L log/sidekiq.log
exit 0
