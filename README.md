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
# enter development environment
./build_and_run.sh Cylinder3D

# build spconv (runtime detection of cuda architecture)
cd /tmp/spconv
python3 setup.py install
cd /workspace

# train (e.g.):
# SemanticKitti
CUDA_VISIBLE_DEVICES=0 python3 -u segmenters/Cylinder3D/train_cylinder_asym.py -y config/Cylinder3D/SemanticKitti.yaml

# nuScenes
# preprocess data according to https://mmdetection3d.readthedocs.io/en/stable/datasets/nuscenes_det.html
CUDA_VISIBLE_DEVICES=0 python3 -u segmenters/Cylinder3D/train_cylinder_asym_nuscenes.py -y config/Cylinder3D/nuScenes.yaml

```

### COARSE3D

```bash
# enter build environment
./build_and_run.sh COARSE3D

# prepare data
cd segmenters/COARSE3D/tasks/prepare_data
python3 gen_sem_weak_label_rand_grid.py --dataset SemanticKITTI --dataset_root=/workspace/data/SemanticKitti/dataset/sequences/ --dataset_save=/workspace/results/COARSE3D/SemanticKitti/sequences/ --data_config_path=/workspace/segmenters/COARSE3D/pc_processor/dataset/semantic_kitti/semantic-kitti.yaml

# train
cd /workspace/segmenters/COARSE3D/tasks/weak_segmentation
CUDA_VISIBLE_DEVICES="0" python3 -m torch.distributed.launch --nproc_per_node=1 --master_port=26889 --use_env main.py /workspace/config/COARSE3D/SemanticKitti.yaml
```
