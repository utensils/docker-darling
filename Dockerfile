FROM ubuntu:18.04

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
        vim \
        wget \
        xz-utils; \
    rm -rf /var/lib/apt/lists/*;

# Setup sudo access
RUN set -xe; \
    echo "darling ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers;

# Clone and build osxcross
ARG OSXCROSS_GIT_REF="master"
RUN set -xe; \
    git clone https://github.com/tpoechtrager/osxcross.git; \
    cd /osxcross; \
    git checkout ${OSXCROSS_GIT_REF}; \
    cd /osxcross/tarballs; \
    wget "https://github.com/jamesbrink/osxcross-resources/raw/master/MacOSX10.11.sdk.tar.xz"; \
    cd /osxcross; \
    UNATTENDED="true" ./build.sh; \
    UNATTENDED="true" PATH="/osxcross/target/bin:/usr/local/bin:$PATH" MACOSX_DEPLOYMENT_TARGET="10.11" /osxcross/target/bin/osxcross-macports install openssl qt5 db48 boost miniupnpc;

# Build Darling
ARG DARLING_GIT_REF="master"
RUN set -xe; \
    git clone --recurse-submodules https://github.com/darlinghq/darling.git /home/darling;

# Include path for linux 5.1
COPY --chown=darling:darling ./linux-5.1.patch /home/darling/src/lkm

# We break this step up for local caching purposes
RUN set -xe; \
    echo "${DARLING_GIT_REF}" > /home/darling/version.txt; \
    cd /home/darling; \
    git checkout ${DARLING_GIT_REF}; \
    mkdir -p /home/darling/build; \
    cd /home/darling/src/lkm; \
    patch -p1 < linux-5.1.patch; \
    cd /home/darling/build; \
    cmake ..; \
    make -j"$(nproc)"; \
    make install; \
    cp /home/darling/build/src/startup/rtsig.h /home/darling/rtsig.h ;\
    rm -rf /usr/src/linux-*; \
    rm -rf /home/darling/build; \
    mkdir -p /home/darling/build/src/startup; \
    mv /home/darling/rtsig.h /home/darling/src/startup/rtsig.h; \
    chown -R darling:darling /home/darling;

# Download kernel-header scripts
RUN set -xe; \
    ls ; \
    apt-get update; \
    apt-get install -y curl; \
    cd /usr/local; \
    git clone https://github.com/jamesbrink/kernel-headers.git; \
    rm -rf /var/lib/apt/lists/*;

# Build arguments.
ARG VCS_REF
ARG BUILD_DATE
ARG VERSION

# Labels / Metadata.
LABEL maintainer="James Brink, brink.james@gmail.com" \
    org.label-schema.decription="darling ($VERSION)" \
    org.label-schema.version="git - $DARLING_GIT_REF" \
    org.label-schema.name="darling" \
    org.label-schema.build-date="$BUILD_DATE" \
    org.label-schema.vcs-ref="$VCS_REF" \
    org.label-schema.vcs-url="https://github.com/jamesbrink/docker-darling.git" \
    org.label-schema.schema-version="1.0.0-rc1"

# Copy our entrypoint into the container.
COPY ./runtime-assets /

# Setup our environment variables.
ENV PATH="/usr/local/bin:$PATH"

# Drop down to our unprivileged user.
USER darling

# Set our working directory.
WORKDIR /home/darling

# Setup our volume for bringing apps into container.
VOLUME /mnt/apps

# COPY Xcode.dmg /home/darling/Xcode.dmg

# Set the entrypoint.
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Set the default command
CMD ["/bin/bash"]
