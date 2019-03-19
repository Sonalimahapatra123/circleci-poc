#!/bin/bash
if ["$CIRCLE_JOB" == "BUILD" ]; then
  apk update && apk -v --update add \
                            python \
                            py-pip \
                            groff \
                            less \
                            mailcap \
                            && \
                            pip install --upgrade awscli==1.14.5 s3cmd==2.0.1 python-magic && \
                            apk -v --purge del py-pip && \
                            rm /var/cache/apk/*
else                            
  apt-get update && apt-get install -y awscli
fi

aws configure set aws_access_key_id $AWS_ACCESS_KEY_DEV_OPS_OWN_ACCOUNT
aws configure set aws_secret_access_key $AWS_SECRET_KEY_DEV_OPS_OWN_ACCOUNT
aws configure set default.region us-east-1
temp_msg=`echo "CIRCLECI JOB STATUS: JOB NAME IS ${CIRCLE_JOB} IS $1" | tr [a-z] [A-Z]`
aws sns publish --topic-arn "arn:aws:sns:us-east-1:546124439885:circleci_each_job_status" --message "${temp_msg}" --subject "${temp_msg}"