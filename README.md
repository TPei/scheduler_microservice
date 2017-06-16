# scheduling microservice [![Build Status](https://travis-ci.org/TPei/scheduler_microservice.svg?branch=master)](https://travis-ci.org/TPei/scheduler_microservice)
A simple microservice that will call a specified endpoint with a specified payload at a specified interval ¯\\_(ツ)_/¯

![Alt text](/raml_demo.png?raw=true "Raml")

## How to use
- deploy to wherever (sidekiq and main docker images can be created from source)
  - web container
  - sidekiq container
  - redis
- can receive POST requests to `/schedule` with endpoint (url), payload (json) and interval (in seconds) -> returns id
- can receive DELETE request to `/schedule/{id}` to unschedule / stop
  job execution

## Dev environment
`docker-compose up -d` (-d so that you don't connect to the log console)

Go to: http://localhost:4567/v1/documentation to check out endpoints are offered and what input / output data is expected

### Running specs etc
- `docker-compose up -d`
- `docker exec -it scheduler_microservice_web_1 /bin/bash` to connect to a shell
- `bundle exec rspec` to run tests
- `bundle exec rubocop` to run linter
