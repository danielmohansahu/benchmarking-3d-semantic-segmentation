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
```


## Training

### Cylinder3D

```bash
./build_and_run.sh Cylinder3D

```

### COARSE3D

```bash
# enter build environment
./build_and_run.sh COARSE3D

# prepare data
python3 segmenters/COARSE3D/tasks/prepare_data/gen_sem_weak_label_rand_grid.py --dataset SemanticKITTI --dataset_root=`pwd`/data/SemanticKitti/dataset/sequences/ --dataset_save=`pwd`/results/COARSE3D/SemanticKitti/sequences/ --data_config_path=`pwd`/segmenters/COARSE3D/pc_processor/dataset/semantic_kitti/semantic-kitti.yaml
```
