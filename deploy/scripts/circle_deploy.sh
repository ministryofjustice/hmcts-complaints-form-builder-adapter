#!/usr/bin/env sh

set -e -u -o pipefail

CONFIG_FILE="/tmp/helm_deploy.yaml"
environment_name=$1
kube_token=$2

echo -n "$KUBE_CERTIFICATE_AUTHORITY" | base64 -d > .kube_certificate_authority
echo "kubectl configure cluster"
kubectl config set-cluster "$KUBE_CLUSTER" --certificate-authority=".kube_certificate_authority" --server="$KUBE_SERVER"
kubectl config set-credentials "circleci_${environment_name}" --token="${kube_token}"
kubectl config set-context "circleci_${environment_name}" --cluster="$KUBE_CLUSTER" --user="circleci_${environment_name}" --namespace="hmcts-complaints-formbuilder-adapter-${environment_name}"
kubectl config use-context "circleci_${environment_name}"

echo "apply kubernetes changes to ${environment_name}"

helm template deploy/ --set circleSha1=$CIRCLE_SHA1 --set environmentName=$environment_name > $CONFIG_FILE
kubectl apply -f $CONFIG_FILE -n hmcts-complaints-formbuilder-adapter-$environment_name
