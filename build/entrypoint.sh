#!/bin/bash

set -e

: ${GCLOUD_REGISTRY:=eu.gcr.io/tradeshift-base}
: ${IMAGE:=$GITHUB_REPOSITORY}
: ${ARGS:=} # Default: empty build args
: ${TAG:=$GITHUB_SHA}
: ${DEFAULT_BRANCH_TAG:=true}
: ${LATEST:=true}
echo "Building $GCLOUD_REGISTRY/$IMAGE:$TAG"
docker build $ARGS -t $GCLOUD_REGISTRY/$IMAGE:$TAG .

if [ $LATEST = true ]; then
  docker tag $GCLOUD_REGISTRY/$IMAGE:$TAG $GCLOUD_REGISTRY/$IMAGE:latest
fi

if [ "$DEFAULT_BRANCH_TAG" = "true" ]; then
  BRANCH=$(echo $GITHUB_REF | rev | cut -f 1 -d / | rev)
  if [ "$BRANCH" = "master" ]; then # TODO
    docker tag $GCLOUD_REGISTRY/$IMAGE:$TAG $GCLOUD_REGISTRY/$IMAGE:$BRANCH
  fi
fi

docker tag $GCLOUD_REGISTRY/$IMAGE:$TAG $GCLOUD_REGISTRY/$IMAGE:${{ github.event.pull_request.head.sha }}
