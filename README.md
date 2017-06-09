# scheduling microservice [![Build Status](https://travis-ci.org/TPei/scheduler_microservice.svg?branch=develop)](https://travis-ci.org/TPei/scheduler_microservice)
A simple microservice that will call a specified endpoint with a specified payload at a specified interval Edit


## How to run
`docker-compose up -d` (-d so that you don't connect to the log console)
Go to: http://localhost:4567/v1/

## Running specs
`docker-compose up -d`
`docker exec -it cp17scheduler_web_1 /bin/bash` to connect to a shell
`bundle install` if necessary
`bundle exec rspec` to run tests
`bundle exec rubocop` to run linter
