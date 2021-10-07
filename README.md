You might use the Vagrant. (https://github.com/developer-onizuka/setup-centos8)

Then you might skip #0~#8 below. Go to #9.

# 0. Install Ubuntu 20.04 as Virtual Machine with GPU on KVM. See the URL below.
https://github.com/developer-onizuka/virtualMachine_withGPU

Note that you don't need install any GPU libraries in Host Machine. You don't need to install nvidia-driver even in Guest Linux Machine, neither. 
```
OptiPlex-5050:~$ dpkg -l |grep -i nvidia
OptiPlex-5050:~$ (no result)
```
```
Guest-Machine:~$ dpkg -l |grep -i nvidia
Guest-Machine:~$ (no result)
```

# 0-1. Check Kernel version of Virtual Machine
5.11 was failed while in the step #3. You might use 5.4 instead of 5.11.
```
$ uname -r
5.4.0-42-generic
```

You might use below for installing 5.4.0-42 in your machine.
```
$ sudo visudo
$ sudo vi /etc/apt/apt.conf.d/20auto-upgrades 
$ sudo apt-get install linux-image-5.4.0-42-generic linux-headers-5.4.0-42-generic linux-modules-extra-5.4.0-42-generic
$ sudo vi /etc/default/grub
Edit like this; GRUB_TIMEOUT=0 --> GRUB_TIMEOUT=-1
$ sudo update-grub
$ reboot
$ dpkg --get-selections |grep linux-
$ sudo apt-get autoremove --purge linux-{headers,image,modules}-5.11.0-34
$ dpkg --get-selections |grep linux-
$ sudo apt-get autoremove --purge linux-{headers,image,modules}-5.8.0-43
$ sudo vi /etc/default/grub
Edit like this; GRUB_TIMEOUT=-1 --> GRUB_TIMEOUT=0
$ sudo update-grub
$ shutdown -h now
```

# 1. Install Docker on Virtual Machine
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

If you find "Unsupported distribution! Check https://nvidia.github.io/nvidia-docker", then you might use below instead of above.
```
curl -s -L https://nvidia.github.io/nvidia-docker/ubuntu20.04/nvidia-docker.list | \ 
sudo tee /etc/apt/sources.list.d/nvidia-docker.list
```

# 3. Install Containerized Nvidia-driver on Virtual Machine
```
$ sudo sed -i 's/^#root/root/' /etc/nvidia-container-runtime/config.toml
$ sudo tee /etc/modules-load.d/ipmi.conf <<< "ipmi_msghandler"   && sudo tee /etc/modprobe.d/blacklist-nouveau.conf <<< "blacklist nouveau"   && sudo tee -a /etc/modprobe.d/blacklist-nouveau.conf <<< "options nouveau modeset=0"
$ sudo update-initramfs -u
$ sudo reboot
$ sudo docker pull nvcr.io/nvidia/driver:470.57.02-ubuntu20.04
$ sudo docker run --name nvidia-driver -itd --rm --privileged --pid=host -v /run/nvidia:/run/nvidia:shared -v /var/log:/var/log  nvcr.io/nvidia/driver:470.57.02-ubuntu20.04
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

# 6. Install Libraries into the nvidia/cuda:11.4.1-cudnn8-devel-ubuntu20.04 downloaded
```
$ xhost +
$ sudo docker run -itd -v /tmp/test:/mnt -v /tmp/.X11-unix:/tmp/.X11-unix --device /dev/video0:/dev/video0:mwr -e DISPLAY=$DISPLAY --gpus all --rm --name="camera" nvidia/cuda:11.4.1-cudnn8-devel-ubuntu20.04
$ sudo docker exec -it camera /bin/bash
```
```
# echo "deb http://dk.archive.ubuntu.com/ubuntu/ bionic main universe" >> /etc/apt/sources.list
# apt-get update
# apt-get install -y gcc-6 g++-6
# apt-get install -y libx11-dev

# apt-get install -y python3-distutils python3-setuptools python3-pip
# DEBIAN_FRONTEND='noninteractive' apt-get install -y cmake libopenblas-dev liblapack-dev libjpeg-dev
# apt-get install -y git
# git clone https://github.com/davisking/dlib.git
# cd dlib
# mkdir build
# cd build
# cmake .. -DDLIB_USE_CUDA=1 -DUSE_AVX_INSTRUCTIONS=1 -DCUDA_HOST_COMPILER=/usr/bin/gcc-6
# cmake --build .
# cd .. 

# apt-get install -y python3-opencv
# pip3 install face_recognition
# cd /mnt
# cp -p test.py /tmp
# cp -p train.pkl /tmp
# /tmp/test.py 
```

# 7. Create the face_recognizer by using Dockerfile on Virtual Machine
If you can run the test above, you might use the Dockerfile attached.
```
$ mkdir face_recognizer
$ cd face_recognizer
$ ls
Dockerfile
test.py
train.pkl
$ sudo docker build -t face_recognizer:1.0.0 .

$ sudo docker images
REPOSITORY              TAG                               IMAGE ID       CREATED          SIZE
face_recognizer         1.0.0                             5f3503aedca0   35 seconds ago   10.6GB
nvcr.io/nvidia/driver   470.57.02-ubuntu20.04             15eeb055da6a   5 weeks ago      826MB
nvidia/cuda             11.4.1-cudnn8-devel-ubuntu20.04   132256fd7024   5 weeks ago      8.83GB
```

# 8. Run the container on Virtual Machine (After Booting Virtual Machine)
```
$ xhost +
$ sudo docker run -itd --gpus all --name="face" --rm -v /tmp/.X11-unix:/tmp/.X11-unix --device /dev/video0:/dev/video0:mwr -e DISPLAY=$DISPLAY face_recognizer:1.0.0
```
Or following. An example below is the over-write of ENTORYPOINT, so you can run any python scripts which are put on /mnt and using dlib and GPU's libraries.
```
$ xhost +
$ sudo docker run -itd --gpus all --name="face" --rm -v work:/mnt -v /tmp/.X11-unix:/tmp/.X11-unix --device /dev/video0:/dev/video0:mwr --entrypoint "/mnt/test.py" -e DISPLAY=$DISPLAY face_recognizer:1.0.0
```

# 9. X11 Forwarding settings in Virtual Machine

https://qiita.com/hoto17296/items/7c1ba10c1575c6c38105
```
$ ssh -X vagrant@<IP Address of Virtual Machine>
vagrant@gpu:~$ sudo apt-get install -y x11-xserver-utils
vagrant@gpu:~$ sudo apt-get install -y x11-apps

vagrant@gpu:~$ sudo su
root@gpu:/home/vagrant# cat <<EOF >> /etc/ssh/sshd_config
X11Forwarding yes
X11DisplayOffset 10
X11UseLocalhost no
EOF

vagrant@gpu:~$ sudo service sshd restart
vagrant@gpu:~$ echo $DISPLAY
gpu:10.0
vagrant@gpu:~$ exit

$ ssh -X vagrant@<IP Address of Virtual Machine>
vagrant@<IP Address of Virtual Machine>'s password: 
Last login: Wed Oct  6 11:35:58 2021 from 192.168.xxx.xxx
/usr/bin/xauth:  file /home/vagrant/.Xauthority does not exist
vagrant@gpu:~$ xeyes

vagrant@gpu:~$ sudo docker run -itd --net host -v /tmp/test:/mnt -v /tmp/.X11-unix:/tmp/.X11-unix -v $HOME/.Xauthority:/root/.Xauthority --device /dev/video0:/dev/video0:mwr -e DISPLAY=$DISPLAY --gpus all --rm --name="camera" face_recognizer:1.0.0
```
