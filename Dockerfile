FROM quay.io/toolbx/ubuntu-toolbox:22.04

######## Start by configuring nvidia ########

######## Clone NVIDIA Repository ########

RUN git clone https://gitlab.com/nvidia/container-images/cuda.git

######## NVIDIA Base Dockerfile ########

ENV NVARCH x86_64

ENV NVIDIA_REQUIRE_CUDA "cuda>=11.8 brand=tesla,driver>=470,driver<471 brand=unknown,driver>=470,driver<471 brand=nvidia,driver>=470,driver<471 brand=nvidiartx,driver>=470,driver<471 brand=geforce,driver>=470,driver<471 brand=geforcertx,driver>=470,driver<471 brand=quadro,driver>=470,driver<471 brand=quadrortx,driver>=470,driver<471 brand=titan,driver>=470,driver<471 brand=titanrtx,driver>=470,driver<471"
ENV NV_CUDA_CUDART_VERSION 11.8.89-1
ENV NV_CUDA_COMPAT_PACKAGE cuda-compat-11-8

LABEL maintainer "NVIDIA CORPORATION <cudatools@nvidia.com>"

RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 curl ca-certificates && \
    curl -fsSLO https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/${NVARCH}/cuda-keyring_1.0-1_all.deb && \
    dpkg -i cuda-keyring_1.0-1_all.deb && \
    apt-get purge --autoremove -y curl \
    && rm -rf /var/lib/apt/lists/*

ENV CUDA_VERSION 11.8.0

# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-11-8=${NV_CUDA_CUDART_VERSION} \
    ${NV_CUDA_COMPAT_PACKAGE} \
    && rm -rf /var/lib/apt/lists/*

# Required for nvidia-docker v1
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf \
    && echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

RUN cp cuda/NGC-DL-CONTAINER-LICENSE /

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

######## NVIDIA Runtime Dockerfile ########

ENV NV_CUDA_LIB_VERSION 11.8.0-1

ENV NV_NVTX_VERSION 11.8.86-1
ENV NV_LIBNPP_VERSION 11.8.0.86-1
ENV NV_LIBNPP_PACKAGE libnpp-11-8=${NV_LIBNPP_VERSION}
ENV NV_LIBCUSPARSE_VERSION 11.7.5.86-1

ENV NV_LIBCUBLAS_PACKAGE_NAME libcublas-11-8
ENV NV_LIBCUBLAS_VERSION 11.11.3.6-1
ENV NV_LIBCUBLAS_PACKAGE ${NV_LIBCUBLAS_PACKAGE_NAME}=${NV_LIBCUBLAS_VERSION}

ENV NV_LIBNCCL_PACKAGE_NAME libnccl2
ENV NV_LIBNCCL_PACKAGE_VERSION 2.15.5-1
ENV NCCL_VERSION 2.15.5-1
ENV NV_LIBNCCL_PACKAGE ${NV_LIBNCCL_PACKAGE_NAME}=${NV_LIBNCCL_PACKAGE_VERSION}+cuda11.8

LABEL maintainer "NVIDIA CORPORATION <cudatools@nvidia.com>"

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-libraries-11-8=${NV_CUDA_LIB_VERSION} \
    ${NV_LIBNPP_PACKAGE} \
    cuda-nvtx-11-8=${NV_NVTX_VERSION} \
    libcusparse-11-8=${NV_LIBCUSPARSE_VERSION} \
    ${NV_LIBCUBLAS_PACKAGE} \
    ${NV_LIBNCCL_PACKAGE} \
    && rm -rf /var/lib/apt/lists/*

# Keep apt from auto upgrading the cublas and nccl packages. See https://gitlab.com/nvidia/container-images/cuda/-/issues/88
RUN apt-mark hold ${NV_LIBCUBLAS_PACKAGE_NAME} ${NV_LIBNCCL_PACKAGE_NAME}

# Add entrypoint items
RUN mkdir -p /opt/nvidia/entrypoint.d
RUN cp -r cuda/entrypoint.d/ /opt/nvidia/entrypoint.d/
RUN cp cuda/nvidia_entrypoint.sh /opt/nvidia/
ENV NVIDIA_PRODUCT_NAME="CUDA"
ENTRYPOINT ["/opt/nvidia/nvidia_entrypoint.sh"]

######## NVIDIA Devel Dockerfile ########

ENV NV_CUDA_LIB_VERSION "11.8.0-1"

ENV NV_CUDA_CUDART_DEV_VERSION 11.8.89-1
ENV NV_NVML_DEV_VERSION 11.8.86-1
ENV NV_LIBCUSPARSE_DEV_VERSION 11.7.5.86-1
ENV NV_LIBNPP_DEV_VERSION 11.8.0.86-1
ENV NV_LIBNPP_DEV_PACKAGE libnpp-dev-11-8=${NV_LIBNPP_DEV_VERSION}

ENV NV_LIBCUBLAS_DEV_VERSION 11.11.3.6-1
ENV NV_LIBCUBLAS_DEV_PACKAGE_NAME libcublas-dev-11-8
ENV NV_LIBCUBLAS_DEV_PACKAGE ${NV_LIBCUBLAS_DEV_PACKAGE_NAME}=${NV_LIBCUBLAS_DEV_VERSION}

ENV NV_CUDA_NSIGHT_COMPUTE_VERSION 11.8.0-1
ENV NV_CUDA_NSIGHT_COMPUTE_DEV_PACKAGE cuda-nsight-compute-11-8=${NV_CUDA_NSIGHT_COMPUTE_VERSION}

ENV NV_NVPROF_VERSION 11.8.87-1
ENV NV_NVPROF_DEV_PACKAGE cuda-nvprof-11-8=${NV_NVPROF_VERSION}

ENV NV_LIBNCCL_DEV_PACKAGE_NAME libnccl-dev
ENV NV_LIBNCCL_DEV_PACKAGE_VERSION 2.15.5-1
ENV NCCL_VERSION 2.15.5-1
ENV NV_LIBNCCL_DEV_PACKAGE ${NV_LIBNCCL_DEV_PACKAGE_NAME}=${NV_LIBNCCL_DEV_PACKAGE_VERSION}+cuda11.8

LABEL maintainer "NVIDIA CORPORATION <cudatools@nvidia.com>"

RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-cudart-dev-11-8=${NV_CUDA_CUDART_DEV_VERSION} \
    cuda-command-line-tools-11-8=${NV_CUDA_LIB_VERSION} \
    cuda-minimal-build-11-8=${NV_CUDA_LIB_VERSION} \
    cuda-libraries-dev-11-8=${NV_CUDA_LIB_VERSION} \
    cuda-nvml-dev-11-8=${NV_NVML_DEV_VERSION} \
    ${NV_NVPROF_DEV_PACKAGE} \
    ${NV_LIBNPP_DEV_PACKAGE} \
    libcusparse-dev-11-8=${NV_LIBCUSPARSE_DEV_VERSION} \
    ${NV_LIBCUBLAS_DEV_PACKAGE} \
    ${NV_LIBNCCL_DEV_PACKAGE} \
    ${NV_CUDA_NSIGHT_COMPUTE_DEV_PACKAGE} \
    && rm -rf /var/lib/apt/lists/*

# Keep apt from auto upgrading the cublas and nccl packages. See https://gitlab.com/nvidia/container-images/cuda/-/issues/88
RUN apt-mark hold ${NV_LIBCUBLAS_DEV_PACKAGE_NAME} ${NV_LIBNCCL_DEV_PACKAGE_NAME}
ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs

######## cudnn8-runtime ########

ENV NV_CUDNN_VERSION 8.9.6.50
ENV NV_CUDNN_PACKAGE_NAME "libcudnn8"

ENV NV_CUDNN_PACKAGE "libcudnn8=$NV_CUDNN_VERSION-1+cuda11.8"
ENV NV_CUDNN_PACKAGE_DEV "libcudnn8-dev=$NV_CUDNN_VERSION-1+cuda11.8"

LABEL maintainer "NVIDIA CORPORATION <cudatools@nvidia.com>"
LABEL com.nvidia.cudnn.version="${NV_CUDNN_VERSION}"

RUN apt-get update && apt-get install -y --no-install-recommends \
    ${NV_CUDNN_PACKAGE} \
    ${NV_CUDNN_PACKAGE_DEV} \
    && apt-mark hold ${NV_CUDNN_PACKAGE_NAME} \
    && rm -rf /var/lib/apt/lists/*

######## Remove NVIDIA Repository ########

RUN rm -rf cuda/

######## Now configure visp ########

# Update aptitude with new repo
RUN apt-get update

# Install packages
RUN apt-get install -y \
    sudo \
    build-essential \
    cmake \
    git \
    net-tools \
    iputils-ping \
    # Recommended ViSP 3rd parties
    libopencv-dev \
    libx11-dev \
    liblapack-dev \
    libeigen3-dev \
    libdc1394-dev \
    libv4l-dev \
    libzbar-dev \
    # Other optional 3rd parties
    libpcl-dev \
    libcoin-dev \
    libjpeg-turbo8-dev \
    libpng-dev \
    libogre-1.9-dev \
    libois-dev \
    libdmtx-dev \
    libgsl-dev \
    python3-pip

RUN pip install cmake

# # Get visp
# RUN mkdir visp-ws
# RUN cd /visp-ws \
#     && git clone https://github.com/lagadic/visp
#
# # Build visp
# RUN cd /visp-ws \
#     && mkdir visp-build \
#     && cd visp-build \
#     && cmake ../visp \
#     && make -j$(nproc)


#TODO: instalar miniconda, instalar openCV de source version 4.7, ver basch history. Ha 3 conda envs, mas so o megapose server e necessario