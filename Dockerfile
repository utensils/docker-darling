ARG BASE_IMAGE
FROM ${BASE_IMAGE} as builder

# Install deps.
RUN set -xe; \
    dpkg --add-architecture i386; \
    apt-get update; \
    apt-get install -y \
        bison \
        clang \
        cmake \
        flex \
        gcc-multilib \
        git \
        kmod \
        libbsd-dev \
        libc6-dev:i386 \
        libcairo2-dev \
        libcap2-bin \
        libegl1-mesa-dev \
        libelf-dev \
        libfontconfig1-dev \
        libfreetype6-dev \
        libfreetype6-dev:i386 \
        libfuse-dev \
        libgl1-mesa-dev \
        libtiff5-dev \
        libudev-dev \
        libxml2-dev \
        linux-headers-generic \
        pkg-config \
        sudo \
        xz-utils; \
    rm -rf /var/lib/apt/lists/*;

# Clone Darling
ARG DARLING_GIT_REF="master"
RUN set -xe; \
    mkdir -p /usr/local/src; \
    git clone --recurse-submodules https://github.com/darlinghq/darling.git /usr/local/src/darling;

WORKDIR /usr/local/src/darling

# Checkout working gitref
RUN set -xe; \
    git checkout ${DARLING_GIT_REF}; \
    git submodule update --recursive; \
    mkdir -p /usr/local/src/darling/build;

# Set our working directory to the build dir
WORKDIR /usr/local/src/darling/build

# Configure Darling Build
RUN set -xe; \
    cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr/local ..;

# Build Darling
RUN set -xe; \
    make -j$(getconf _NPROCESSORS_ONLN);

# Install Darling    
RUN set -xe; \
    make install; \
    cp /usr/local/src/darling/build/src/startup/rtsig.h /usr/local/src/darling/rtsig.h ;\
    mkdir -p /usr/local/src/darling/build/src/startup; \
    mv /usr/local/src/darling/rtsig.h /usr/local/src/darling/src/startup/rtsig.h;

# Copy the modified CMakeLists.txt used for building LKM
COPY build-assets /

# Move LKM dependencies into single location
RUN set -xe; \
    cd /usr/local/src/; \
    rm -rf darling/build; \
    mv darling darling-full; \
    mkdir -p darling/src; \
    mkdir -p darling/build/src; \
    mv /usr/local/src/docker-darling/CMakeLists.txt /usr/local/src/darling/CMakeLists.txt ;\
    mv /usr/local/src/darling-full/src/lkm /usr/local/src/darling/src/lkm ;\
    mv /usr/local/src/darling-full/cmake /usr/local/src/darling/cmake; \
    mv /usr/local/src/darling-full/src/bootstrap_cmds /usr/local/src/darling/src/bootstrap_cmds; \
    mv /usr/local/src/darling-full/platform-include /usr/local/src/darling/platform-include; \
    mv /usr/local/src/darling-full/kernel-include /usr/local/src/darling/kernel-include; \
    mv /usr/local/src/darling-full/src/CMakeLists.txt /usr/local/src/darling/src/CMakeLists.txt; \
    mv /usr/local/src/darling-full/src/startup /usr/local/src/darling/build/src/startup; \
    rm -rf /usr/local/src/darling-full; \
    rm -rf /usr/local/src/docker-darling; \
    cd /usr/local/src/darling/build; \
    cmake ..;

# Create final runtime image
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# Create our group & user.
RUN set -xe; \
    groupadd -g 1000 darling; \
    useradd -g darling -u 1000 -s /bin/sh -d /home/darling darling;

# Install deps.
RUN set -xe; \
    dpkg --add-architecture i386; \
    apt-get update; \
    apt-get install -y \
        bison \
        clang \
        cmake \
        flex \
        kmod \
        make \
        sudo; \
    rm -rf /var/lib/apt/lists/*;

# Setup sudo access
RUN set -xe; \
    echo "darling ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers;

# Copy our Darling build from previous stage
COPY --from=builder /usr/local /usr/local

# Copy the needed sources to build kernel module
COPY --from=builder /usr/local/src/darling /usr/local/src/darling

# Labels / Metadata.
ARG VCS_REF
ARG BUILD_DATE
ARG VERSION
LABEL \
    org.opencontainers.image.authors="James Brink <brink.james@gmail.com>" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.description="darling lite version (no kernel module) ($VERSION)" \
    org.opencontainers.image.revision="${VCS_REF}" \
    org.opencontainers.image.source="https://github.com/utensils/docker-darling.git" \
    org.opencontainers.image.title="darling (lite)" \
    org.opencontainers.image.vendor="Utensils" \
    org.opencontainers.image.version="git - ${DARLING_GIT_REF}"

# Copy our entrypoint into the container.
COPY ./runtime-assets/ /

# Setup our environment variables.
ENV PATH="/usr/local/bin:$PATH"

# Drop down to our unprivileged user.
USER darling

# Set our working directory.
WORKDIR /home/darling

# Set the entrypoint.
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Set the default command
CMD ["/usr/local/bin/darling", "shell"]
