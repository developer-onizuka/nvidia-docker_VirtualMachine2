# 0. Install Ubuntu 20.04 as Virtual Machine with GPU on KVM. See the URL below.
https://github.com/developer-onizuka/virtualMachine_withGPU

Note that you don't need install any GPU libraries in Host Machine. Even nvidia-driver in Host Machine. You don't need to install nvidia-driver even in Guest Linux Machine. 
```
OptiPlex-5050:~$ dpkg -l |grep -i nvidia
OptiPlex-5050:~$ (no result)
```
```
VirtualMachine:~$ dpkg -l |grep -i nvidia
VirtualMachine:~$ (no result)
```

# 0. Check Kernel version
5.11 was failed while in the step #3. You might use 5.4 instead of 5.11.
```
$ uname -r
5.4.0-42-generic
```

You might use for installing 5.4.0-42 in your machine.
```
$ sudo visudo
$ sudo vi /etc/apt/apt.conf.d/20auto-upgrades 
$ sudo apt-get install linux-image-5.4.0-42-generic linux-headers-5.4.0-42-generic linux-modules-extra-5.4.0-42-generic
$ sudo vi /etc/default/grub
$ sudo update-grub
$ reboot
$ dpkg --get-selections |grep linux-
$ sudo apt-get autoremove --purge linux-{headers,image,modules}-5.11.0-34
$ dpkg --get-selections |grep linux-
$ sudo apt-get autoremove --purge linux-{headers,image,modules}-5.8.0-43
$ sudo vi /etc/default/grub
$ sudo update-grub
$ shutdown -h now
```

# 1. Install Docker on Virtual Machine and changing directory to store images because it is too large.
```
$ sudo apt-get update
$ sudo apt-get install -y docker.io
```

# 2. Install nvidia-docker on Virtual Machine
```
$ sudo apt-get install -y curl
$ curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
$ distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
$ curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list
$ sudo apt-get update
$ sudo apt-get install -y nvidia-docker2
$ sudo systemctl restart docker
```

# 3. Install Containerized Nvidia-driver on Virtual Machine
```
$ sudo sed -i 's/^#root/root/' /etc/nvidia-container-runtime/config.toml
$ sudo tee /etc/modules-load.d/ipmi.conf <<< "ipmi_msghandler"   && sudo tee /etc/modprobe.d/blacklist-nouveau.conf <<< "blacklist nouveau"   && sudo tee -a /etc/modprobe.d/blacklist-nouveau.conf <<< "options nouveau modeset=0"
$ sudo update-initramfs -u
$ sudo reboot
$ sudo docker pull nvcr.io/nvidia/driver:470.57.02-ubuntu20.04
$ sudo docker run --name nvidia-driver -d --privileged --pid=host -v /run/nvidia:/run/nvidia:shared -v /var/log:/var/log --restart=unless-stopped nvcr.io/nvidia/driver:470.57.02-ubuntu20.04
$ sudo docker logs -f nvidia-driver
...
Mounting NVIDIA driver rootfs...
Done, now waiting for signal

$ lsmod |grep -i nvidia
nvidia_modeset       1196032  1
nvidia_uvm           1032192  0
nvidia              35270656  19 nvidia_uvm,nvidia_modeset
drm                   491520  7 drm_kms_helper,drm_vram_helper,bochs_drm,nvidia,ttm

$ ls /run/nvidia/driver/
bin   drivers  lib    libx32  NGC-DL-CONTAINER-LICENSE  root  srv  usr
boot  etc      lib32  media   opt                       run   sys  var
dev   home     lib64  mnt     proc                      sbin  tmp
```

# 4. Run some containers with "--gpus all"
```
$ sudo docker run -it --rm --gpus all --name="ubuntu" ubuntu:20.04
root@8184a351a918:/# nvidia-smi
Mon Sep 13 02:09:05 2021       
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 470.57.02    Driver Version: 470.57.02    CUDA Version: 11.4     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  Quadro P1000        On   | 00000000:04:00.0 Off |                  N/A |
| 34%   45C    P8    N/A /  N/A |      1MiB /  4040MiB |      0%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
```

# 5. Pull CUDA and cuDNN container
```
$ sudo docker pull nvidia/cuda:11.4.1-cudnn8-devel-ubuntu20.04
```

```
$ xhost +
$ sudo docker run -itd -v /tmp/test:/mnt -v /tmp/.X11-unix:/tmp/.X11-unix --device /dev/video0:/dev/video0:mwr -e DISPLAY=$DISPLAY --gpus all --rm --name="camera" nvidia/cuda:11.4.1-cudnn8-devel-ubuntu20.04
$ sudo docker exec -it camera /bin/bash



echo "deb http://dk.archive.ubuntu.com/ubuntu/ bionic main universe" >> /etc/apt/sources.list
apt-get update
apt-get install -y gcc-6 g++-6
apt-get install -y libx11-dev

apt-get install -y python3-distutils python3-setuptools python3-pip
DEBIAN_FRONTEND='noninteractive' apt-get install -y cmake libopenblas-dev liblapack-dev libjpeg-dev
apt-get install -y git
git clone https://github.com/davisking/dlib.git
cd dlib
mkdir build
cd build
cmake .. -DDLIB_USE_CUDA=1 -DUSE_AVX_INSTRUCTIONS=1 -DCUDA_HOST_COMPILER=/usr/bin/gcc-6
cmake --build .
cd .. 

apt-get install -y python3-opencv
pip3 install face_recognition
cd /mnt
cp -p test.py /tmp
cp -p train.pkl /tmp
/tmp/test.py 
```


