apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: fb-datastore-cron-db-sweeper-{{ .Values.environmentName }}
  namespace: formbuilder-platform-{{ .Values.environmentName }}
spec:
  schedule: "0 * * * *"
  successfulJobsHistoryLimit: 0
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hmcts-complaints-formbuilder-adapter-{{ .Values.environmentName }}
            image: 754256621582.dkr.ecr.eu-west-2.amazonaws.com/form-builder/hmcts-complaints-formbuilder-adapter:{{ .Values.app_image_tag }}
            args:
            - /bin/sh
            - -c
            - bundle exec rails runner 'Usecase::SweepDatabase.new(attachments_gateway: Gateway::Attachments.new).call(7.days.ago)'
            securityContext:
              runAsUser: 1001
            imagePullPolicy: Always
            envFrom:
              - configMapRef:
                  name: hmcts-complaints-formbuilder-adapter-env-{{ .Values.environmentName }}
            env:
              - name: DATABASE_URL
                valueFrom:
                  secretKeyRef:
                    name: rds-instance-hmcts-complaints-adapter-{{ .Values.environmentName }}
                    key: url
              - name: SECRET_KEY_BASE
                valueFrom:
                  secretKeyRef:
                    name: hmcts-complaints-formbuilder-adapter-secret
                    key: SECRET_KEY_BASE
              - name: SENTRY_DSN
                valueFrom:
                  secretKeyRef:
                    name: hmcts-complaints-formbuilder-adapter-secret
                    key: SENTRY_DSN
          restartPolicy: Never
