#!/usr/bin/env sh

set -e -u -o pipefail

CONFIG_FILE="/tmp/helm_deploy.yaml"

image_tag=$1
environment_name=$2
kube_token=$3

get_secrets() {
    GIT_SSH_COMMAND='ssh -v -i ~/.ssh/id_rsa_7ee744bea14b4e3c56653a94195002cc -o "IdentitiesOnly=yes"' git clone git@github.com:ministryofjustice/hmcts-complaints-formbuilder-adapter-deploy.git deploy-config
    echo $ENCODED_GIT_CRYPT_KEY | base64 -d > /root/circle/git_crypt.key
    cd deploy-config && git-crypt unlock /root/circle/git_crypt.key && cd -
}

deploy_with_secrets() {
    echo -n "$KUBE_CERTIFICATE_AUTHORITY" | base64 -d > .kube_certificate_authority
    kubectl config set-cluster "$KUBE_CLUSTER" --certificate-authority=".kube_certificate_authority" --server="$KUBE_SERVER"
    kubectl config set-credentials "circleci_${environment_name}" --token="${kube_token}"
    kubectl config set-context "circleci_${environment_name}" --cluster="$KUBE_CLUSTER" --user="circleci_${environment_name}" --namespace="hmcts-complaints-formbuilder-adapter-${environment_name}"
    kubectl config use-context "circleci_${environment_name}"

    helm template deploy/ \
         --set imagetag=$image_tag \
         --set environmentName=$environment_name \
         > $CONFIG_FILE

    echo "---" >> $CONFIG_FILE
    cat deploy-config/secrets/${environment_name}_values.yaml >> $CONFIG_FILE

    kubectl apply -f $CONFIG_FILE -n hmcts-complaints-formbuilder-adapter-$environment_name
}

main() {
    echo "Getting secrets"
    get_secrets

    echo "deploying ${environment_name}"
    deploy_with_secrets
}

main
