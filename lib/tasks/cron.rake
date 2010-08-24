task(:cron => :environment) do
  if Time.now.hour == 0 # run at midnight
    #increment number in DB User.send_reminders
  end
end