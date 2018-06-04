# Create Docker container that can run afq analysis.

# Start with the Matlab r2017b runtime container
FROM  flywheel/matlab-mcr:v93.1
MAINTAINER Michael Perry <lmperry@stanford.edu>

ENV FLYWHEEL /flywheel/v0
WORKDIR ${FLYWHEEL}
COPY run ${FLYWHEEL}/run

# Because we're coming in from a Matlab-MCR we need to unset LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH ""

###########################
# Configure neurodebian (https://github.com/neurodebian/dockerfiles/blob/master/dockerfiles/xenial-non-free/Dockerfile)
RUN set -x \
	&& apt-get update \
	&& { \
		which gpg \
		|| apt-get install -y --no-install-recommends gnupg \
	; } \
	&& { \
		gpg --version | grep -q '^gpg (GnuPG) 1\.' \
		|| apt-get install -y --no-install-recommends dirmngr \
	; } \
	&& rm -rf /var/lib/apt/lists/*

RUN set -x \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys DD95CC430502E37EF840ACEEA5D32F012649A5A9 \
	&& gpg --export DD95CC430502E37EF840ACEEA5D32F012649A5A9 > /etc/apt/trusted.gpg.d/neurodebian.gpg \
	&& rm -rf "$GNUPGHOME" \
	&& apt-key list | grep neurodebian

RUN { \
	echo 'deb http://neuro.debian.net/debian xenial main'; \
	echo 'deb http://neuro.debian.net/debian data main'; \
	echo '#deb-src http://neuro.debian.net/debian-devel xenial main'; \
} > /etc/apt/sources.list.d/neurodebian.sources.list

RUN sed -i -e 's,main *$,main contrib non-free,g' /etc/apt/sources.list.d/neurodebian.sources.list; grep -q 'deb .* multiverse$' /etc/apt/sources.list || sed -i -e 's,universe *$,universe multiverse,g' /etc/apt/sources.list


############################
# Install dependencies
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --force-yes \
    xvfb \
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
    ants


############################
# MRTRIX 3
RUN apt-get install -y \
    git \
    g++ \
    bsdtar \
    python \
    python-numpy \
    libeigen3-dev \
    zlib1g-dev \
    libqt4-opengl-dev \
    libgl1-mesa-dev \
    libfftw3-dev \
    libtiff5-dev

ENV mrtrix3COMMIT=8cef83213c4dcce7be1296849bda2b097004dd0c
RUN curl -#L  https://github.com/MRtrix3/mrtrix3/archive/$mrtrix3COMMIT.zip | bsdtar -xf- -C /usr/lib
WORKDIR /usr/lib/mrtrix3-${mrtrix3COMMIT}/
RUN chmod -R +rwx /usr/lib/mrtrix3-${mrtrix3COMMIT}
RUN  ./configure && \
    ./build && \
    ./set_path

ENV PATH /usr/lib/mrtrix3/bin:$PATH


############################

# Configure entrypoint
RUN chmod +x ${FLYWHEEL}/*
ENTRYPOINT ["/flywheel/v0/run"]
COPY manifest.json ${FLYWHEEL}/manifest.json
