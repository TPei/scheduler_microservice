#!/usr/bin/env bash
set -ex

bundle exec rake db:recreate
bundle exec rake db:migrate
