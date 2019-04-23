#!/bin/bash
set -ex

# Ensure AppCenter CLI installed
if which appcenter > /dev/null; then
  echo "AppCenter CLI already installed."
else
  echo "AppCenter CLI is not installed. Installing..."
  npm install -g appcenter-cli
fi

# Change the working dir if necessary
if [ ! -z "${react_native_project_root}" ] ; then
    echo "==> Switching to react native project root: ${react_native_project_root}"
    cd "${react_native_project_root}"
    if [ $? -ne 0 ] ; then
        echo " [!] Failed to switch to react native project root: ${react_native_project_root}"
        exit 1
    fi
fi

appcenter codepush release-react -a $app_id --token $api_token --quiet $options --deployment-name $deployment

LABEL=`appcenter codepush deployment list -a $app_id --token $api_token --output json | jq ".[] | if index(\"$deployment\") == 0 then .[1] else null end | select(.) | split(\"\n\") | .[0] | split(\": \") | .[1]" | tr -d '"'`
envman add --key CODEPUSH_LABEL --value $LABEL

exit 0
