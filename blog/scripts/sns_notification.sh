#!/bin/bash
apt-get update && apt-get install -y awscli
aws configure set aws_access_key_id $AWS_ACCESS_KEY_DEV_OPS_OWN_ACCOUNT
aws configure set aws_secret_access_key $AWS_SECRET_KEY_DEV_OPS_OWN_ACCOUNT
aws configure set default.region us-east-1
aws sns publish --topic-arn "arn:aws:sns:us-east-1:546124439885:circleci_each_job_status" --message echo ("CIRCLECI JOB STATUS: JOB NAME IS ${CIRCLE_JOB} $1" | tr [a-z] [A-Z]) --subject " JOB NAME IS ${CIRCLE_JOB} $1"