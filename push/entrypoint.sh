#!/bin/bash -e

: ${GCLOUD_REGISTRY:=eu.gcr.io/tradeshift-base}
: ${IMAGE:=$GITHUB_REPOSITORY}
: ${TAG:=}
: ${DEFAULT_BRANCH_TAG:=true}
: ${LATEST:=true}

if [ -z "$TAG" ]; then
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    if [ "$BRANCH" = "master" ]; then
        TAG=$(git rev-parse HEAD)
    else
        # Assume not master means we are on a branch with that wierd github merge commit
        TAG=$(git rev-parse HEAD^)
    fi
fi

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
