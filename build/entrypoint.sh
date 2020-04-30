#!/bin/bash

set -e

: ${GCLOUD_REGISTRY:=eu.gcr.io}
: ${IMAGE:=$GITHUB_REPOSITORY}
: ${ARGS:=} # Default: empty build args
: ${TAG:=$GITHUB_SHA}
: ${DEFAULT_BRANCH_TAG:=true}
: ${LATEST:=true}
: ${WORKDIR:=.}
echo "Building $GCLOUD_REGISTRY/$IMAGE:$TAG in $WORKDIR"
docker build $ARGS -t $GCLOUD_REGISTRY/$IMAGE:$TAG $WORKDIR

if [ $LATEST = true ]; then
  docker tag $GCLOUD_REGISTRY/$IMAGE:$TAG $GCLOUD_REGISTRY/$IMAGE:latest
fi

if [ "$DEFAULT_BRANCH_TAG" = "true" ]; then
  BRANCH=$(echo $GITHUB_REF | rev | cut -f 1 -d / | rev)
  if [ "$BRANCH" = "master" ]; then # TODO
    docker tag $GCLOUD_REGISTRY/$IMAGE:$TAG $GCLOUD_REGISTRY/$IMAGE:$BRANCH
  fi
fi
