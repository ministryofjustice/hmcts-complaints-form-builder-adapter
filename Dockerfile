FROM ruby:2.6.4-alpine3.9

ARG UID

RUN apk add build-base postgresql-contrib postgresql-dev bash tzdata

RUN addgroup -g 1001 -S appgroup && \
  adduser -u 1001 -S appuser -G appgroup

WORKDIR /app
ENV HOME /app

COPY Gemfile* .ruby-version ./

RUN gem install bundler
RUN bundle install --no-cache

COPY . .

RUN chown -R 1001:appgroup /app

USER 1001

ENV APP_PORT 3000
ARG RAILS_ENV
EXPOSE $APP_PORT

CMD bundle exec rake db:migrate && bundle exec rails s -p ${APP_PORT} --binding=0.0.0.0
