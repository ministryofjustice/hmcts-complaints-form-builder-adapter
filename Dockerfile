FROM ruby:2.6.4-alpine3.9

ARG UID

RUN apk add build-base postgresql-contrib postgresql-dev bash tzdata

RUN addgroup -g ${UID} -S appgroup && \
  adduser -u ${UID} -S appuser -G appgroup

WORKDIR /app
ENV HOME /app

COPY Gemfile* .ruby-version ./

RUN gem install bundler
RUN bundle install --no-cache

COPY . .

RUN chown -R ${UID}:appgroup /app

USER UID

ENV APP_PORT 3000
EXPOSE $APP_PORT

ARG RAILS_ENV='production'
ENV RAILS_ENV=$RAILS_ENV

CMD bundle exec rake db:migrate && bundle exec rails s -p ${APP_PORT} --binding=0.0.0.0
