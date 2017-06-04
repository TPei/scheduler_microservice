
# CP 17 scheduling component

A service that receives inputs via a REST endpoint and then continuously schedules new infection spreading for a pandemic game session using sidekiq.

It mainly acts as a timer, calling a REST endpoint on the main service to simply notify that it's time for a new wave ¯\_(ツ)_/¯. 