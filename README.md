# CP 17 scheduling component

A service that receives inputs via a REST endpoint and then continuously schedules new infection spreading for a pandemic game session using sidekiq.

It mainly acts as a timer, calling a REST endpoint on the main service to simply notify that it's time for a new wave ¯\_(ツ)_/¯. 

## How to run
`docker-compose up -d` (-d so that you don't connect to the log console)
Go to: http://localhost:4567/v1/

## Running specs
`docker-compose up -d`
`docker exec -it cp17scheduler_web_1 /bin/bash` to connect to a shell
`bundle install` if necessary
`bundle exec rspec` to run tests
`bundle exec rubocop` to run linter
