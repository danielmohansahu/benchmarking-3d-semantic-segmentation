#!/usr/bin/bash

# A convenience shell script to build and run a GPU-enabled Docker image.

set -eo pipefail

# get desired segmenter model
USAGE_STR="Usage: ./build_and_run.sh [Cylinder3D, ...]"
if [[ $# != 1 ]]; then
  echo $USAGE_STR
  exit 1
fi
SEGMENTER=$1
echo "Building / running image for $SEGMENTER..."

# get path to here
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# build and tag docker image
IMAGE=benchmark-3d-semantic-segmentaion:$SEGMENTER
docker build --target $SEGMENTER -t $IMAGE -f $SCRIPTPATH/Dockerfile .

# drop into a container
docker run \
    -it \
    --rm \
    --gpus=all \
    --net=host \
    -e DISPLAY \
    -e QT_X11_NO_MITSHM=1 \
    -e XAUTHORITY=/tmp/.docker.xauth \
    -v /tmp/.docker.xauth:/tmp/.docker.xauth \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /etc/localtime:/etc/localtime:ro \
    -v $SCRIPTPATH:/workspace \
    $IMAGE

