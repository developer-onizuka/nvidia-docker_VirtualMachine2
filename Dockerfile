FROM nvidia/cuda:11.4.1-cudnn8-devel-ubuntu20.04
RUN echo "deb http://dk.archive.ubuntu.com/ubuntu/ bionic main universe" >> /etc/apt/sources.list && apt-get update && apt-get -y install gcc-6 g++-6
RUN apt-get update && DEBIAN_FRONTEND='noninteractive' apt-get install -y libx11-dev python3-distutils python3-setuptools python3-pip python3-opencv git cmake libopenblas-dev liblapack-dev libjpeg-dev
RUN git clone https://github.com/davisking/dlib.git && cd dlib/; \
    mkdir build; \
    cd build; \
    cmake .. -DDLIB_USE_CUDA=1 -DUSE_AVX_INSTRUCTIONS=1 -DCUDA_HOST_COMPILER=/usr/bin/gcc-6; \
    cmake --build .; \
    cd .. ; \
    python3 setup.py install --set DLIB_USE_CUDA=1 --set USE_AVX_INSTRUCTIONS=1 --set CUDA_HOST_COMPILER=/usr/bin/gcc-6
RUN rm -rf /dlib && pip3 install face_recognition
COPY train.pkl /tmp
COPY test.py /tmp
ENTRYPOINT /tmp/test.py
