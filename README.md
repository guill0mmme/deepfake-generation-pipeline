# Face Swapping pipeline implementation 

## Overview
Used and modified SimSwap project repository for provided pretrined checkpoints for inference. Also used the training script for custom trained model checkpoint and used the tarined checkpoint for inference as well.

## Preparation
### Installation
```
# Personal Access Token (PAT) have to be acquired before cloning the repo

# clone project
!git clone --branch "dev/df_gen_pipeline" "https://oauth2:{gitlab_pat}@git.uni-wuppertal.de/tmdt/projects/deepfake/deepfake_generation.git"
cd deepfake_generation

# create conda environment
conda create -n myenv python=3.9
conda activate myenv

# install requirements
pip install -r requirements.txt
```

### Important
Face detection will be performed on CPU. To run it on GPU you need to install onnx gpu runtime:

```pip install onnxruntime-gpu==1.11.1```

and modify one line of code in ```...Anaconda3\envs\myenv\Lib\site-packages\insightface\model_zoo\model_zoo.py```

Here, instead of passing **None** as the second argument to the onnx inference session
```angular2html
class ModelRouter:
    def __init__(self, onnx_file):
        self.onnx_file = onnx_file

    def get_model(self):
        session = onnxruntime.InferenceSession(self.onnx_file, None)
        input_cfg = session.get_inputs()[0]
```
pass a list of providers
```angular2html
class ModelRouter:
    def __init__(self, onnx_file):
        self.onnx_file = onnx_file

    def get_model(self):
        session = onnxruntime.InferenceSession(self.onnx_file, providers=['CUDAExecutionProvider', 'CPUExecutionProvider'])
        input_cfg = session.get_inputs()[0]
```
Otherwise simply use CPU onnx runtime with only a minor performance drop.

### Weights
#### Weights for all pre-trained models get downloaded automatically by model_loader.py script & weights are stored in & fetched from a GitHub public repo

You can also download weights manually and put inside `weights` folder:

- weights/<a href="https://github.com/tsyncIO/model-weights-faceswap/releases/download/v1.0.0/face_detector_scrfd_10g_bnkps.onnx">face_detector_scrfd_10g_bnkps.onnx</a>
- weights/<a href="https://github.com/tsyncIO/model-weights-faceswap/releases/download/v1.0.0/arcface_net.jit">arcface_net.jit</a>
- weights/<a href="https://github.com/tsyncIO/model-weights-faceswap/releases/download/v1.0.0/parsing_model_79999_iter.pth">79999_iter.pth</a>
- weights/<a href="https://github.com/tsyncIO/model-weights-faceswap/releases/download/v1.0.0/simswap_224_latest_net_G.pth">simswap_224_latest_net_G.pth</a> - official 224x224 model
- weights/<a href="https://github.com/mike9251/simswap-inference-pytorch/releases/download/weights/simswap_512_390000_net_G.pth">simswap_512_390000_net_G.pth</a> - unofficial 512x512 model (I took it <a href="https://github.com/neuralchen/SimSwap/issues/255">here</a>).
- weights/<a href="https://github.com/tsyncIO/model-weights-faceswap/releases/download/v1.0.0/GFPGANv1.4_ema.pth">GFPGANv1.4_ema.pth</a>
- weights/<a href="https://github.com/tsyncIO/model-weights-faceswap/releases/download/v1.0.0/blend_module.jit">blend_module.jit</a>


```

### Command line App
This repository supports inference in several modes, which can be easily configured with config files in the **configs** folder.
- **replace all faces on a target image / folder with images**
```angular2html
python app.py --config-name=run_image.yaml
```

- **replace all faces on a video**
```angular2html
python app.py --config-name=run_video.yaml
```

- **replace a specific face on a target image / folder with images**
```angular2html
python app.py --config-name=run_image_specific.yaml
```

- **replace a specific face on a video**
```angular2html
python app.py --config-name=run_video_specific.yaml
```

Config files contain two main parts:

- **data**
  - *id_image* - source image, identity of this person will be transferred.
  - *att_image* - target image, attributes of the person on this image will be mixed with the person's identity from the source image. Here you can also specify a folder with multiple images - identity translation will be applied to all images in the folder.
  - *specific_id_image* - a specific person on the *att_image* you would like to replace, leaving others untouched (if there's any other person).
  - *att_video* - the same as *att_image*
  - *clean_work_dir* - whether remove temp folder with images or not (for video configs only).


- **pipeline**
  - *face_detector_weights* - path to the weights file OR an empty string ("") for automatic weights downloading.
  - *face_id_weights* - path to the weights file OR an empty string ("") for automatic weights downloading.
  - *parsing_model_weights* - path to the weights file OR an empty string ("") for automatic weights downloading.
  - *simswap_weights* - path to the weights file OR an empty string ("") for automatic weights downloading.
  - *gfpgan_weights* - path to the weights file OR an empty string ("") for automatic weights downloading.
  - *device* - whether you want to run the application using GPU or CPU.
  - *crop_size* - size of images SimSwap models works with.
  - *checkpoint_type* - the official model works with 224x224 crops and has different pre/post processings (imagenet like). Latest official repository allows you to train your own models, but the architecture and pre/post processings are slightly different (1. removed Tanh from the last layer; 2. normalization to [0...1] range). **If you run the official 224x224 model then set this parameter to "official_224", otherwise "none".**
  - *face_alignment_type* - affects reference face key points coordinates. **Possible values are "ffhq" and "none". Try both of them to see which one works better for your data.**
  - *smooth_mask_kernel_size* - a non-zero value. It's used for the post-processing mask size attenuation. You might want to play with this parameter.
  - *smooth_mask_iter* - a non-zero value. The number of times a face mask is smoothed.
  - *smooth_mask_threshold* - controls the face mask saturation. Valid values are in range [0.0...1.0]. Tune this parameter if there are artifacts around swapped faces.
  - *face_detector_threshold* - values in range [0.0...1.0]. Higher value reduces probability of FP detections but increases the probability of FN.
  - *specific_latent_match_threshold* - values in range [0.0...inf]. Usually takes small values around 0.05.
  - *enhance_output* - whether to apply GFPGAN model or not as a post-processing step.


### Overriding parameters with CMD
Every parameter in a config file can be overridden by specifying it directly with CMD. For example:

```angular2html
python app.py --config-name=run_image.yaml data.specific_id_image="path/to/the/image" pipeline.smooth_mask_kernel_size=20
```


## Acknowledgements
<!--ts-->
* [SimSwap Official](https://github.com/neuralchen/SimSwap)
* [SimSwap Unofficial](https://github.com/mike9251/simswap-inference-pytorch)
* [Insightface](https://github.com/deepinsight/insightface)
* [Face-parsing.PyTorch](https://github.com/zllrunning/face-parsing.PyTorch)
* [BiSeNet](https://github.com/CoinCheung/BiSeNet)
* [GFPGAN](https://github.com/TencentARC/GFPGAN)
<!--te-->
