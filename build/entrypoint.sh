#!/bin/bash

set -e

: ${GCLOUD_REGISTRY:=eu.gcr.io}
: ${IMAGE:=$GITHUB_REPOSITORY}
: ${ARGS:=} # Default: empty build args
: ${TAG:=$GITHUB_SHA}
: ${DEFAULT_BRANCH_TAG:=true}
: ${LATEST:=true}
: ${WORKDIR:=.}


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

echo "Building $GCLOUD_REGISTRY/$IMAGE:$TAG in $WORKDIR"
docker build $ARGS -t $GCLOUD_REGISTRY/$IMAGE:$TAG $WORKDIR

# Always tag with the sha
echo "Tagging with GITHUB_SHA $GCLOUD_REGISTRY/$IMAGE:${GITHUB_SHA}"
docker tag $GCLOUD_REGISTRY/$IMAGE:$TAG $GCLOUD_REGISTRY/$IMAGE:${GITHUB_SHA}

echo "Tagging with REAL_HEAD $GCLOUD_REGISTRY/$IMAGE:${REAL_HEAD}"
# And always with the real sha, somtimes this is the same then this would be a noop
docker tag $GCLOUD_REGISTRY/$IMAGE:$TAG $GCLOUD_REGISTRY/$IMAGE:${REAL_HEAD}

if [ $LATEST = true ]; then
  docker tag $GCLOUD_REGISTRY/$IMAGE:$TAG $GCLOUD_REGISTRY/$IMAGE:latest
fi

if [ "$DEFAULT_BRANCH_TAG" = "true" ]; then
  BRANCH=$(echo $GITHUB_REF | rev | cut -f 1 -d / | rev)
  if [ "$BRANCH" = "master" ]; then # TODO
    docker tag $GCLOUD_REGISTRY/$IMAGE:$TAG $GCLOUD_REGISTRY/$IMAGE:$BRANCH
  fi
fi
