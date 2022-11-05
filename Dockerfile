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
ARG CUDA_VERSION="11.3.1"
ARG UBUNTU_VERSION="20.04"
ARG TORCH_VERSION="1.12.1"

# Start from a base Nvidia/CUDA capable Ubuntu image
FROM nvidia/cuda:${CUDA_VERSION}-cudnn8-devel-ubuntu${UBUNTU_VERSION} AS base
ARG CUDA_VERSION
ARG TORCH_VERSION

# use bash for everything
SHELL ["/bin/bash", "-c"]

# update and upgrade; install some utilities
RUN apt-get update -qq && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
      vim \
      byobu \
      git \
      cmake \
    && rm -rf /var/lib/apt/lists/*

### Cylinder3D specific dependencies
FROM base AS Cylinder3D
ARG CUDA_VERSION
ARG TORCH_VERSION

# install the things needed for Cylinder3D
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
      python3-dev \
      python3-pip \
      libboost-dev \
      libgl-dev \
      libglib2.0-dev \
    && rm -rf /var/lib/apt/lists/*

# install pip dependencies
COPY config/Cylinder3D/requirements.txt /tmp/requirements.txt
RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install torch==${TORCH_VERSION} --extra-index-url https://download.pytorch.org/whl/cu113 \
    && python3 -m pip install torch-scatter -f https://data.pyg.org/whl/torch-${TORCH_VERSION}+cu113.html \
    && python3 -m pip install -r /tmp/requirements.txt

# install spconv (old, non-pypy version required)
RUN git clone https://github.com/traveller59/spconv.git --recursive -b v1.2.1 /tmp/spconv 
COPY config/Cylinder3D/spconv.patch /tmp/spconv/spconv.patch
RUN cd /tmp/spconv \
      && git apply spconv.patch

# drop into a byobu shell
WORKDIR /workspace
CMD byobu

### COARDE3D specific dependencies
FROM base AS COARSE3D
ARG CUDA_VERSION

# install the things needed for Cylinder3D
RUN apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
      python3-dev \
      python3-pip \
      libgl-dev \
      libglib2.0-dev \
    && rm -rf /var/lib/apt/lists/*

# install pip dependencies
COPY config/COARSE3D/requirements.txt /tmp/requirements.txt
RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install torch==1.8.0+cu111 torchvision==0.9.0+cu111 torchaudio==0.8.0 --extra-index-url https://download.pytorch.org/whl/cu111 \
    && python3 -m pip install -r /tmp/requirements.txt

# drop into a byobu shell
WORKDIR /workspace
CMD byobu
