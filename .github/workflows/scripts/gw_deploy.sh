#!/usr/bin/env bash

set -e

##
# Read parameters from cfn.json
##
ROLE_ARN=$(jq -r ".targetAccountRoleArn" < cfn.json)
ARTIFACT_NAME=$(jq -r ".artifactsBucket" < cfn.json)
PREFIX=$(jq -r ".prefix" < cfn.json)
TARGET_ENVIRONMENT=$(jq -r ".environment" < cfn.json)
PROFILE=$(jq -r ".profile" < cfn.json)
ACCESS_KEY=$(jq -r ".access_key" < cfn.json)
SECRET_KEY=$(jq -r ".secret_key" < cfn.json)


# do a aws ocnfigure in single line reading the secrets from the github secrets
aws configure set aws_access_key_id ${ACCESS_KEY}
aws configure set aws_secret_access_key ${SECRET_KEY}
aws configure set region = eu-west-2

##
# Assuming the roles required to deploy on the target account.
##
ASSUMED_CREDENTIALS=$(aws sts assume-role --role-arn "${ROLE_ARN}" --role-session-name deploy_"${TARGET_ENVIRONMENT} --profile default")
AWS_ACCESS_KEY_ID=$(echo "${ASSUMED_CREDENTIALS}" | jq -r .Credentials.AccessKeyId)
AWS_SECRET_ACCESS_KEY=$(echo "${ASSUMED_CREDENTIALS}" | jq -r .Credentials.SecretAccessKey)
AWS_SESSION_TOKEN=$(echo "${ASSUMED_CREDENTIALS}" | jq -r .Credentials.SessionToken)

export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
export AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN}"

##
# Package infrastructure
##
cd "${GITHUB_WORKSPACE}"/infrastructure
aws cloudformation package \
    --template-file infrastructure/aws-stacks/s3updates-stack.yml \
    --s3-bucket "${ARTIFACT_NAME}" \
    --output-template-file infrastructure/aws-stacks/s3updates-stack_release.yaml

cd "${GITHUB_WORKSPACE}"


##
# Deploy infrastructure stack.
##
aws cloudformation deploy \
    --template-file "${GITHUB_WORKSPACE}"/infrastructure/aws-stacks/s3updates-stack_release.yaml \
    --stack-name "${TARGET_ENVIRONMENT}"-"${PREFIX}"-org-api-stack \
	--s3-bucket "${ARTIFACT_NAME}" \
	--capabilities CAPABILITY_AUTO_EXPAND CAPABILITY_NAMED_IAM \
	--no-fail-on-empty-changeset \
	--parameter-overrides \
	Environment="${TARGET_ENVIRONMENT}" \
    Prefix="${PREFIX}" \
    BucketName="${ARTIFACT_NAME}" \
    