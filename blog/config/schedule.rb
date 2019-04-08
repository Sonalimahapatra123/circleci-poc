every 1.minute do
  set :output, Dir.pwd + "/../../log/one_min_task.log"
  rake "cync:run_every_minute_task"
end





