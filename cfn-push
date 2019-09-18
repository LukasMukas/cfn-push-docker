#!/bin/bash

helpFunction()
{
   echo "Lint a cfn script and then upload it to an s3 bucket"
   echo "Usage: $0 {file} bucket"
   echo "To lint the template without uploading it do not pass a bucket parameter"
   exit 1 # Exit script after printing help
}

if [ -z "$1" ]
then 
  echo "You must provide a file and optionally a bucket"
  exit 1
fi

fail=`cfn-lint $1`
if [ "$fail" == "" ];
then 
  echo "lint passed"
  fail=`cfn_nag $1`
  if [[ "$fail" =~ "Failures count: 0" ]]; 
  then
    if [[ ! "$fail" =~ "Warnings count: 0" ]];
    then 
      echo "$fail"
    fi
    echo "nag passed"
    if [ -z $2 ];
    then 
      echo "No bucket was provided"
      exit 0
    fi
    echo "Uploading the template to $2" 
    aws s3 cp $1 $2
  else 
    echo "$fail"
    exit 1
  fi
else
  echo "$fail"
  exit 1
fi
