FROM ruby:2.3.1

ENV LANG C.UTF-8

WORKDIR /mnt

COPY Gemfile .
COPY Gemfile.lock .
RUN mkdir vendor
# COPY vendor/cache vendor/cache
RUN bundle install --binstubs

COPY . .

EXPOSE 4567
CMD ["./bin/run"]
