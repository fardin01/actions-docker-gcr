#!/bin/bash

set -e

: ${GCLOUD_REGISTRY:=eu.gcr.io}
: ${IMAGE:=$GITHUB_REPOSITORY}
: ${TAG:=$GITHUB_SHA}
: ${DEFAULT_BRANCH_TAG:=true}
: ${LATEST:=true}

if [ -n "${GCLOUD_SERVICE_ACCOUNT_KEY}" ]; then
  echo "Logging into gcr.io with GCLOUD_SERVICE_ACCOUNT_KEY..."
  echo ${GCLOUD_SERVICE_ACCOUNT_KEY} | base64 --decode --ignore-garbage > /tmp/key.json
  gcloud auth activate-service-account --quiet --key-file /tmp/key.json
  gcloud auth configure-docker --quiet
else
  echo "GCLOUD_SERVICE_ACCOUNT_KEY was empty, not performing auth" 1>&2
fi

echo "Pushing $GCLOUD_REGISTRY/$IMAGE:$TAG"
echo "Pushing $GCLOUD_REGISTRY/$IMAGE:$GITHUB_SHA"
docker push $GCLOUD_REGISTRY/$IMAGE:$TAG

if [ $LATEST = true ]; then
  docker push $GCLOUD_REGISTRY/$IMAGE:latest
fi
