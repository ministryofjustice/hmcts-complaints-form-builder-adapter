FROM ruby:2.7.2-alpine3.12

RUN apk add build-base postgresql-contrib postgresql-dev bash tzdata

ARG UID='1001'
RUN addgroup -S appgroup && \
  adduser -u ${UID} -S appuser -G appgroup

WORKDIR /app
ENV HOME /app

RUN chown appuser:appgroup /app

COPY --chown=appuser:appgroup Gemfile Gemfile.lock .ruby-version ./

RUN gem install bundler

ARG BUNDLE_FLAGS="--jobs 2 --no-cache --without development test"
RUN bundle install ${BUNDLE_FLAGS}

COPY --chown=appuser:appgroup . .

ADD --chown=appuser:appgroup https://s3.amazonaws.com/rds-downloads/rds-ca-2019-root.pem ./rds-ca-2019-root.pem
ADD --chown=appuser:appgroup https://s3.amazonaws.com/rds-downloads/rds-ca-2015-root.pem ./rds-ca-2015-root.pem
RUN cat ./rds-ca-2019-root.pem > ./rds-ca-bundle-root.crt
RUN cat ./rds-ca-2015-root.pem >> ./rds-ca-bundle-root.crt
RUN chown appuser:appgroup ./rds-ca-bundle-root.crt

USER 1001

ARG RAILS_ENV='production'
ENV RAILS_ENV=$RAILS_ENV

CMD bin/delayed_job --queues=send_complaints,send_correspondences run
