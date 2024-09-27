#!/usr/bin/env bash

# This script looks for the AWS S3 bucket and DynamoDB Table objects with the standardized names.
# Returns the outcome of the search for each one: success(0) or failure.
# No arguments needed to be passed: the names are evaluated from the AWS profile.

name_suffix="terraform-tfstate"
account_id="$( aws sts get-caller-identity | jq -r '.Account' )"
region="$( aws configure get region )"
backend_name="${account_id}-${name_suffix}"

aws s3api list-buckets | jq -r '.Buckets' | egrep -q -x -e "^${backend_name}$"
AWS_S3_STATUS=$?

aws dynamodb list-tables --region $region | jq -r '.TableNames[]' | egrep -q -x -e "^${backend_name}$"
AWS_DDB_STATUS=$?

jq -n --arg aws_s3_status "$AWS_S3_STATUS" --arg aws_ddb_status "$AWS_DDB_STATUS" \
    '{"aws_s3_status":$aws_s3_status, "aws_ddb_status":$aws_ddb_status}'

