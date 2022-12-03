# benchmarking-3d-semantic-segmentation

Benchmarking state of the art 3D Semantic Segmentation classifiers against popular datasets.

Summary test matrix:

| Segmenter / Dataset | [SemanticKitti](http://www.semantic-kitti.org/dataset.html) | [nuScenes](https://www.nuscenes.org/nuscenes) | [RELLIS3D](https://unmannedlab.github.io/research/RELLIS-3D) | [Semantic3D](http://www.semantic3d.net/) | [OFFSED](https://www.dfki.uni-kl.de/~neigel/offsed.html)
| --- | --- | --- | --- | --- | ---
| [Cylinder3D](https://arxiv.org/pdf/2011.10033.pdf) | | | | |
| [COARSE3D](https://arxiv.org/pdf/2210.01784.pdf) | | | | |
| [2DPASS](https://arxiv.org/pdf/2207.04397.pdf) | | | | |
| [SalsaNext](https://arxiv.org/pdf/2003.03653.pdf) | | | | | 

## Overview and Summary of Results

This project aims to reproduce the performance of various 3D Semantic Segmentation architectures as posited on the [SemanticKitti Segmentation Task](http://semantic-kitti.org/tasks.html) and [paperswithcode](https://paperswithcode.com/). Furthermore, we evaluate the performance of these segmenters on more challenging datasets to evaluate their performance in less controlled environments.

Rough metrics are collected on each of these permutations of dataset / segmenter. These metrics are not a perfect measure of success, but they help guide the discussion. Each of these was collected on the same hardware (GeForce RTX 2080 SUPER Mobile / Max-Q, Intel Core i7-10750H @2.6GHz x 12, 32 GB RAM). Due to the nature of some of the segmenters we weren't able to implement fixed software version control (e.g. for PyTorch).

Summary of collected metrics:

Dataset | Segmenter | mean Intersection Over Union (mIOU) | Overall Accuracy (OA) | Runtime Frequency (hz) | Runtime GPU Usage (GB) | Time to Train (days)
--- | --- | --- | --- | --- | --- | ---
SemanticKitti | Cylinder3D | 61.0 | ??? | 3.0 | 2.9-3.2 | 3.6
SemanticKitti | COARSE3D | ??? | ??? | ??? | ??? | ???
SemanticKitti | 2DPASS | 55.6 | ??? | ??? | ??? | 7.3
SemanticKitti | SalsaNext | 55.5 | ??? | ??? | ??? | 0.8
nuScenes | Cylinder3D | 73.2 | ??? | ??? | ??? | 5.2
nuScenes | COARSE3D | ??? | ??? | ??? | ??? | ???
nuScenes | 2DPASS | ??? | ??? | ??? | ??? | ???
nuScenes | SalsaNext | ??? | ??? | ??? | ??? | ???
RELLIS3D | Cylinder3D | ??? | ??? | ??? | ??? | ???
RELLIS3D | COARSE3D | ??? | ??? | ??? | ??? | ???
RELLIS3D | 2DPASS | ??? | ??? | ??? | ??? | ???
RELLIS3D | SalsaNext | 55.3 | ??? | ??? | ??? | 0.2

## Reproduction

If you're interested in reproducing some of these results the following sections describe how to train and evaluate each combination of model and dataset. Unfortunately the process of getting the data for each dataset is bespoke and cannot be automated (some require online accounts).

### Prerequisites

The development environment is all Docker based. Ensure you have `docker` installed, as well as the proper Nvidia drivers for your machine and `nvidia-docker2` to allow GPU access within a container environment.

### Dataset Collection

Please follow the instructions on the respective dataset website to get them, and ensure they're in the following format:

<details><summary>Click for data directory structure:</summary><br>

```
.
├── data
│   ├── nuScenes
│   │   ├── lidarseg
│   │   ├── maps
│   │   ├── samples
│   │   ├── sweeps
│   │   ├── v1.0-mini
│   │   ├── v1.0-test
│   │   └── v1.0-trainval
│   └── SemanticKitti
│       └── dataset
│           └── sequences
```

</details>

### Training and Evaluation

The following are instructions on how to train and evaluate each supported permutation of dataset and segmenter.

#### Cylinder3D

```bash
# enter development environment
./build_and_run.sh Cylinder3D

# build spconv (runtime detection of cuda architecture)
cd /tmp/spconv
python3 setup.py install
cd /workspace

# train (e.g.):
# SemanticKitti
time CUDA_VISIBLE_DEVICES=0 python3 -u segmenters/Cylinder3D/train_cylinder_asym.py -y config/Cylinder3D/SemanticKitti.yaml

# nuScenes
# preprocess data according to https://mmdetection3d.readthedocs.io/en/stable/datasets/nuscenes_det.html
time CUDA_VISIBLE_DEVICES=0 python3 -u segmenters/Cylinder3D/train_cylinder_asym_nuscenes.py -y config/Cylinder3D/nuScenes.yaml

# Rellis3D
time CUDA_VISIBLE_DEVICES=0 python3 -u segmenters/Cylinder3D/train_cylinder_asym.py -y config/Cylinder3D/Rellis3D.yaml

```

#### COARSE3D

```bash
# enter build environment
./build_and_run.sh COARSE3D

# prepare data
cd segmenters/COARSE3D/tasks/prepare_data
time python3 gen_sem_weak_label_rand_grid.py --dataset SemanticKITTI --dataset_root=/workspace/data/SemanticKitti/dataset/sequences/ --dataset_save=/workspace/results/COARSE3D/SemanticKitti/sequences/ --data_config_path=/workspace/segmenters/COARSE3D/pc_processor/dataset/semantic_kitti/semantic-kitti.yaml

# train
cd /workspace/segmenters/COARSE3D/tasks/weak_segmentation
time CUDA_VISIBLE_DEVICES="0" python3 -m torch.distributed.launch --nproc_per_node=1 --master_port=26889 --use_env main.py /workspace/config/COARSE3D/SemanticKitti.yaml
```

#### 2DPASS

```bash
# enter build environment (build stage is named oddly due to Docker stage constraints)
./build_and_run.sh TWODPASS

# train on semantickitti
cd /workspace/segmenters/2DPASS
time python3 main.py --log_dir 2DPASS_semkitti --config /workspace/config/2DPASS/SemanticKitti.yaml --gpu 0

# train on nuScenes
cd /workspace/segmenters/2DPASS
time python3 main.py --log_dir 2DPASS_nusc --config /workspace/config/2DPASS/nuScenes.yaml --gpu 0

# evaluation (semantickitti)
cd /workspace/segmenters/2DPASS
time python3 main.py --config SemanticKitti.yaml --gpu 0 --test --num_vote 12 --checkpoint /workspace/results/2DPASS/SemanticKitti/model_save.pt

# evaluation (nuscenes)
cd /workspace/segmenters/2DPASS
time python3 main.py --config nuScenes.yaml --gpu 0 --test --num_vote 12 --checkpoint /workspace/results/2DPASS/nuScenes/model_save.pt
```

#### SalsaNext

SalsaNext has some compatibility issues with newer versions of TensorFlow. We had to patch the repo in order to run locally:

```bash
# pre-run step; only do this once!
cd segmenters/SalsaNext && git apply ../../config/SalsaNext/salsanext.patch
```

```bash
# enter development environment
./build_and_run.sh SalsaNext

# train (SemanticKitti)
cd segmenters/SalsaNext
time ./train.sh -d /workspace/data/SemanticKitti/dataset/ -a /workspace/config/SalsaNext/SemanticKitti.yaml -n SalsaNextSemanticKitti -l /workspace/results/SalsaNext/SemanticKitti/logs -c 0

# train (Rellis3D)
cd segmenters/SalsaNext
time ./train.sh -d /workspace/data/Rellis3D/Rellis-3D/ -a /workspace/config/SalsaNext/Rellis3D.yaml -n SalsaNextRellis3D -l /workspace/results/SalsaNext/Rellis3D/logs -r /workspace/config/SalsaNext/Rellis3DLabels.yaml -c 0

```


## References

The following references were invaluable in understanding and selecting specific segmenters and datasets for reproduction and evaluation.

 - Deep Learning for 3D Point Clouds: A Survey [paper](https://arxiv.org/pdf/1912.12033.pdf) [code](https://github.com/The-Learning-And-Vision-Atelier-LAVA/SoTA-Point-Cloud)
