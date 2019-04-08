namespace :cync do

  task :run_every_minute_task => :environment do |t,args|
     Post.create({title: "Title from cron at #{Time.now}",body: "Body from cron at #{Time.now}"})
    end
  end

