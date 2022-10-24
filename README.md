# benchmarking-3d-semantic-segmentation
Benchmarking state of the art 3D Semantic Segmentation classifiers against popular datasets.

## Overview



### Metrics

 - Training speed
 - Runtime speed
 - MIOU
 - GPU / CPU performance
 - 

### Datasets
 - SemanticKitti
 - nuScenes
 - RELLIS3D

## Development Environment

It is recommended to run everything within a Virtual Environment to avoid dependency pollution with your host.

```bash
pip install virtualenv
virtualenv venv
source venv/bin/activate
pip install --upgrade pip
```

From within the virtual environment install all dependencies.

@TODO record exact versions used in testing and set up individual requirements.txt.

```bash
# Cylinder3D
pip install torch
pip install torch-scatter spconv

