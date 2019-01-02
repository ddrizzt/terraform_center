#!/bin/bash
#Please ensure that you had set your own AWS in the parameter.
# Sample:
# export AWS_AK=11111
# export AWS_SK=22222

sed -i "/.*access_key.*=.*/caccess_key = \""$(echo $AWS_AK)"\"" config.tf
sed -i "/.*secret_key.*=.*/csecret_key = \""$(echo $AWS_SK)"\"" config.tf
