# HMCTS Complaints - formbuilder adapter
[![CircleCI](https://circleci.com/gh/ministryofjustice/hmcts-complaints-formbuilder-adapter.svg?style=svg)](https://circleci.com/gh/ministryofjustice/hmcts-complaints-formbuilder-adapter)

This application takes Webhook posts received from [fb-submitter](https://github.com/ministryofjustice/fb-submitter) and forwards them to a instance of [iCasework](https://www.icasework.com/)([docs](https://icasework.atlassian.net/wiki/spaces/UsefulFeedback/pages/15171599/iCasework+REST+APIs)) a backend for managing cases

## Running locally
### Prerequisites
- docker
- docker-compose

## Running
- run `make serve`
- test `make spec`

Note: see the [Makefile](./Makefile) for other cmds

## Production setup
- run `rake auth:generate_key`  to create a secret key for the `JWE_SHARED_KEY` env var
- env var `DATABASE_URL` must point to a postgress db 
