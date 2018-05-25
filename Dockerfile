# Create Docker container that can run afq analysis.

# Start with the Matlab r2017b runtime container
FROM  neurodebian:xenial
MAINTAINER Michael Perry <lmperry@stanford.edu>

ENV FLYWHEEL /flywheel/v0
WORKDIR ${FLYWHEEL}
COPY run ${FLYWHEEL}/run

###########################
# Install dependencies

RUN apt-get update && apt-get install -y --force-yes \
    xvfb \
    software-properties-common \
    xfonts-100dpi \
    xfonts-75dpi \
    xfonts-cyrillic \
    zip \
    unzip \
    python \
    imagemagick \
    wget \
    subversion \
    fsl-5.0-core \
    jq \
    ants \
    xfonts-100dpi \
    xfonts-75dpi \
    xfonts-cyrillic \
    git  \
    python-numpy  \
    libeigen3-dev  \
    zlib1g-dev \
    libqt4-opengl-dev \
    libgl1-mesa-dev \
    libfftw3-dev \
    libtiff5-dev \
    build-essential \
    cmake \
    pkg-config \
    libgdcm-tools \
    bsdtar \
    pigz \
    gzip 

############################
# AFQ

# Add  ants to the system path
ENV PATH /usr/lib/ants:$PATH
ENV mrtrix3COMMIT=8cef83213c4dcce7be1296849bda2b097004dd0c
RUN curl -#L  https://github.com/MRtrix3/mrtrix3/archive/$mrtrix3COMMIT.zip | bsdtar -xf- -C /usr/lib
WORKDIR /usr/lib/mrtrix3-${mrtrix3COMMIT}/
RUN chmod -R +rwx /usr/lib/mrtrix3-${mrtrix3COMMIT}
RUN  ./configure -nogui && ./build &&  ./set_path 

ENV PATH /usr/lib/mrtrix3/bin:$PATH


# Install the MCR dependencies and some things we'll need and download the MCR 
# from Mathworks - silently install it
RUN apt-get -qq update && apt-get -qq install -y xorg  && \
    mkdir /opt/mcr && \
    mkdir /mcr-install && \
    cd /mcr-install && \
    wget -nv http://ssd.mathworks.com/supportfiles/downloads/R2017a/deployment_files/R2017a/installers/glnxa64/MCR_R2017a_glnxa64_installer.zip && \
    unzip MCR_R2017a_glnxa64_installer.zip && \
    ./install -destinationFolder /opt/mcr -agreeToLicense yes -mode silent && \
    cd / && \
    rm -rf /mcr-install

# Configure environment variables for MCR
ENV LD_LIBRARY_PATH /opt/mcr/v92/runtime/glnxa64:/opt/mcr/v92/bin/glnxa64:/opt/mcr/v92/sys/os/glnxa64:/opt/mcr/v92/sys/java/jre/glnxa64/jre/lib/amd64/native_threads:/opt/mcr/v92/sys/java/jre/glnxa64/jre/lib/amd64/server:/opt/mcr/v92/sys/java/jre/glnxa64/jre/lib/amd64:$LD_LIBRARY_PATH 
ENV XAPPLRESDIR /opt/mcr/v92/X11/app-defaults
























############################

# Configure entrypoint
RUN chmod +x ${FLYWHEEL}/*
ENTRYPOINT ["/flywheel/v0/run"]
COPY manifest.json ${FLYWHEEL}/manifest.json

