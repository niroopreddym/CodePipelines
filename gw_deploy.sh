#!/usr/bin/env bash

set -e

##
# Get parameters for stack deployment based on target environment
##
echo "${TARGET_ENVIRONMENT}"
make prepare-environment ENV="${TARGET_ENVIRONMENT}"

##
# Read parameters from cfn.json
##
ROLE_ARN=$(jq -r ".targetAccountRoleArn" < cfn.json)
ARTIFACT_NAME=$(jq -r ".artifactsBucket" < cfn.json)
PREFIX=$(jq -r ".prefix" < cfn.json)
INCLUDE_DOMAIN=$(jq -r ".IncludeDomain" < cfn.json)
INCLUDE_ROLE=$(jq -r ".IncludeRole" < cfn.json)
AUDIT_STREAM_NAME=$(jq -r ".AuditStreamName" < cfn.json)
AUDIT_ROLE_ARN=$(jq -r ".AuditRoleArn" < cfn.json)
DIRECTORY_ARN=$(jq -r ".DirectoryARN" < cfn.json)
SCHEMA_ARN=$(jq -r ".SchemaARN" < cfn.json)
LOCATION_FACET_INDEX=$(jq -r ".LocationFacetIndex" < cfn.json)
SERVICE_FACET_INDEX=$(jq -r ".ServiceFacetIndex" < cfn.json)
ORGANISATION_FACET_INDEX=$(jq -r ".OrganisationFacetIndex" < cfn.json)
SERVICENAME_COMPOSITE_INDEX=$(jq -r ".ServiceNameCompositeIndex" < cfn.json)
LOCATIONNAME_COMPOSITE_INDEX=$(jq -r ".LocationNameCompositeIndex" < cfn.json)
AUTHORISER_RESULT=$(jq -r ".AuthorizerResultTtlInSeconds" < cfn.json)
INCLUDEAPI_VERSIONING_MACRO=$(jq -r ".IncludeAPIVersionMacro" < cfn.json)
LOG_STREAM_NAME=$(jq -r ".LoggingStreamName" < cfn.json)
LOG_ROLE_ARN=$(jq -r ".LoggingRoleArn" < cfn.json)

##
# Assuming the roles required to deploy on the target account.
##
ASSUMED_CREDENTIALS=$(aws sts assume-role --role-arn "${ROLE_ARN}" --role-session-name deploy_"${TARGET_ENVIRONMENT}")
AWS_ACCESS_KEY_ID=$(echo "${ASSUMED_CREDENTIALS}" | jq -r .Credentials.AccessKeyId)
AWS_SECRET_ACCESS_KEY=$(echo "${ASSUMED_CREDENTIALS}" | jq -r .Credentials.SecretAccessKey)
AWS_SESSION_TOKEN=$(echo "${ASSUMED_CREDENTIALS}" | jq -r .Credentials.SessionToken)

export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
export AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN}"

##
# Package infrastructure
##
cd "${WORKSPACE}"/infrastructure
aws cloudformation package \
    --template-file aws-stacks/s3updates-stack.yml \
    --s3-bucket "${ARTIFACT_NAME}" \
    --output-template-file aws-stacks/s3updates-stack_release.yaml

cd "${WORKSPACE}"


##
# Deploy infrastructure stack.
##
aws cloudformation deploy \
    --template-file "${WORKSPACE}"/infrastructure/aws-stacks/s3updates-stack_release.yaml \
    --stack-name "${TARGET_ENVIRONMENT}"-"${PREFIX}"-org-api-stack \
	--s3-bucket "${ARTIFACT_NAME}" \
	--capabilities CAPABILITY_AUTO_EXPAND CAPABILITY_NAMED_IAM \
	--no-fail-on-empty-changeset \
	--parameter-overrides \
	Environment="${TARGET_ENVIRONMENT}" \
	AuthoriserLambdaArn="${AUTHORISER_FUNCTION_ARN}" \
    Prefix="${PREFIX}" \
    Bucket="${ARTIFACT_NAME}" \
    IncludeDomain="${INCLUDE_DOMAIN}" \
    IncludeRole="${INCLUDE_ROLE}" \
    AuditStreamName="${AUDIT_STREAM_NAME}" \
    AuditRoleArn="${AUDIT_ROLE_ARN}" \
    DirectoryARN="${DIRECTORY_ARN}" \
    SchemaARN="${SCHEMA_ARN}" \
    LocationFacetIndex="${LOCATION_FACET_INDEX}" \
    ServiceFacetIndex="${SERVICE_FACET_INDEX}" \
    OrganisationFacetIndex="${ORGANISATION_FACET_INDEX}" \
    LocationNameCompositeIndex="${LOCATIONNAME_COMPOSITE_INDEX}" \
    ServiceNameCompositeIndex="${SERVICENAME_COMPOSITE_INDEX}" \
    AuthorizerResultTtlInSeconds="${AUTHORISER_RESULT}" \
    LogStreamName="${LOG_STREAM_NAME}" \
    LogRoleArn="${LOG_ROLE_ARN}"