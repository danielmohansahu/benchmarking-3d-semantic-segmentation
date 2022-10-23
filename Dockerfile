# Dockerfile for Test / Train environment setup.
# 
# This Dockerfile defines an image for each Segmenter.
# That image contains all the dependencies required to train and
#  evaluate that particular segmenter.
#
# Intended usage (for example):
#
#   docker build . --target Cylinder3D -t seg3d-benchmark:cylinder3d
#

# input args to select CUDA / Ubuntu versions
#  not all permutations supported
#  see https://hub.docker.com/r/nvidia/cuda/tags
ARG CUDA_VERSION="10.2"
ARG UBUNTU_VERSION="18.04"

# Start from a base Nvidia/CUDA capable Ubuntu image
FROM nvidia/cuda:${CUDA_VERSION}-base-ubuntu${UBUNTU_VERSION} AS base

# use bash for everything
SHELL ["/bin/bash", "-c"]

# update and upgrade; install some utilities
RUN apt-get update -qq && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
      vim \
      byobu \
      git \
    && rm -rf /var/lib/apt/lists/*

# Cylinder3D specific dependencies
FROM base AS Cylinder3D

# install the things needed for Cylinder3D
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
      python3-dev \
      python3-pip \
    && rm -rf /var/lib/apt/lists/*

# install pip dependencies
COPY config/Cylinder3D/requirements.txt /tmp/requirements.txt
RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install -r /tmp/requirements.txt

# install spconv (old, non-pypy version required)
RUN git clone https://github.com/traveller59/spconv.git -b v1.2.1 /tmp/spconv \
    && python3 -m pip install -e /tmp/spconv

# drop into a byobu shell
WORKDIR /workspace
CMD byobu
