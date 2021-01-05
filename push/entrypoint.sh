#!/bin/bash

set -e

: ${GCLOUD_REGISTRY:=eu.gcr.io}
: ${IMAGE:=$GITHUB_REPOSITORY}
: ${TAG:=$GITHUB_SHA}
: ${DEFAULT_BRANCH_TAG:=true}
: ${LATEST:=false}
: ${TAGS:=""}

# Sometimes Github runs on a merge commit
REAL_HEAD=$(git rev-parse HEAD)

if [ -n "${GCLOUD_SERVICE_ACCOUNT_KEY}" ]; then
    echo "Logging into gcr.io with GCLOUD_SERVICE_ACCOUNT_KEY..."
    echo ${GCLOUD_SERVICE_ACCOUNT_KEY} | base64 -d > /tmp/key.json
    gcloud auth activate-service-account --quiet --key-file /tmp/key.json
    gcloud auth configure-docker --quiet
else
    echo "GCLOUD_SERVICE_ACCOUNT_KEY was empty, not performing auth" 1>&2
fi

echo "Pushing $GCLOUD_REGISTRY/$IMAGE:$TAG"
docker push $GCLOUD_REGISTRY/$IMAGE:$TAG

echo "Pushing $GCLOUD_REGISTRY/$IMAGE:$GITHUB_SHA"
docker push $GCLOUD_REGISTRY/$IMAGE:$GITHUB_SHA

echo "Pushing $GCLOUD_REGISTRY/$IMAGE:$REAL_HEAD"
# And always with the real sha, somtimes this is the same then this would be a noop
docker push $GCLOUD_REGISTRY/$IMAGE:${REAL_HEAD}

if [ $LATEST = true ]; then
    echo "Pushing $GCLOUD_REGISTRY/$IMAGE:latest"
    docker push $GCLOUD_REGISTRY/$IMAGE:latest
fi

for other_tag in $TAGS
do
  echo "Pushing $GCLOUD_REGISTRY/$IMAGE:$other_tag"
  docker tag $GCLOUD_REGISTRY/$IMAGE:$TAG $GCLOUD_REGISTRY/$IMAGE:$other_tag
  docker push $GCLOUD_REGISTRY/$IMAGE:$other_tag
done
