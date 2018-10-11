FROM ubuntu:18.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install \
                build-essential \
                cmake \
                git \
                mercurial \
                cmake \
                libpng-dev \
                libjpeg-dev \
                libtiff-dev \
                libglu1-mesa-dev \
                libboost-iostreams-dev \
                libboost-program-options-dev \
                libboost-system-dev \
                libboost-serialization-dev \
                libopencv-dev \
                libcgal-dev \
                libcgal-qt5-dev \
                libatlas-base-dev \
                libsuitesparse-dev \
                qt5-default libxxf86vm1 libxxf86vm-dev libxi-dev libxrandr-dev graphviz libcgal-qt5-dev
# Previous line courtesy of https://github.com/open-anatomy/SfM_gui_for_openMVG/blob/master/BUILD_UBUNTU_16_04.md

#Eigen (Required)
WORKDIR /
RUN hg clone https://bitbucket.org/eigen/eigen#3.2
RUN mkdir eigen_build 
WORKDIR /eigen_build
RUN cmake . /eigen
RUN make && make install

#VCGLib (Required)
WORKDIR /
RUN git clone https://github.com/cdcseacave/VCG.git vcglib

# Latest head breaks build for Ubuntu 
# WORKDIR /vcglib
# RUN git checkout b42e3ed7fa1a3861fd35060d40e8cbfe58278100

#Ceres (Required)
WORKDIR /
RUN git clone https://ceres-solver.googlesource.com/ceres-solver ceres-solver
RUN mkdir ceres_build
WORKDIR ceres_build
RUN cmake . /ceres-solver/ -DMINIGLOG=ON -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF
RUN make -j2 && make install

#OpenMVS
WORKDIR /
RUN git clone https://github.com/cdcseacave/openMVS.git openMVS
RUN mkdir openMVS_build

WORKDIR /openMVS_build
RUN cmake . ../openMVS -DCMAKE_BUILD_TYPE=Release -DVCG_DIR="/vcglib"
RUN make -j2 && make install
ENV PATH=/openMVS_build/bin/:$PATH

RUN mkdir /work
WORKDIR /work