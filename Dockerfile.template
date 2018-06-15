FROM ubuntu:18.04

# Build arguments.
ARG VCS_REF
ARG BUILD_DATE
ARG WINE_VERSION="3.0"

# Labels / Metadata.
LABEL maintainer="James Brink, brink.james@gmail.com" \
    decription="darling" \
    version="3.0" \
    org.label-schema.name="darling" \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/jamesbrink/docker-template" \
    org.label-schema.schema-version="1.0.0-rc1"

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

# Clone osxcross
RUN set -xe; \
    git clone https://github.com/tpoechtrager/osxcross.git; \
    cd /osxcross/tarballs; \
    wget "https://github.com/jamesbrink/osxcross-resources/raw/master/MacOSX10.11.sdk.tar.xz";

# Setup SDK 
RUN set -xe; \
    cd /osxcross; \
    UNATTENDED="true" ./build.sh; \
    UNATTENDED="true" PATH="/osxcross/target/bin:/usr/local/bin:$PATH" MACOSX_DEPLOYMENT_TARGET="10.11" /osxcross/target/bin/osxcross-macports install openssl qt5 db48 boost miniupnpc;

# Clone Darling
RUN set -xe; \
    git clone --recurse-submodules https://github.com/darlinghq/darling.git /home/darling; \
    echo "${WINE_VERSION}" > /home/darling/version.txt; \
    chown darling:darling /home/darling/version.txt;

# Build Darling
RUN set -xe; \
    mkdir -p /home/darling/build; \
    cd /home/darling/build; \
    cmake ..; \
    make install -j"$(nproc)"; \
    chown -R darling:darling /home/darling;

# TODO replace this
RUN set -xe; \
    rm -rf /usr/src/linux-headers-4.15.0-22*; \
    cd /usr/local/src/; \
    wget "http://mirror.pseudoform.org/core/os/x86_64/linux-headers-4.16.13-2-x86_64.pkg.tar.xz"; \
    tar xfv linux-headers-4.16.13-2-x86_64.pkg.tar.xz; \
    cp -rv ./usr/lib/* /lib/; \
    cp -rv ./usr/lib/modules/4.16.13-2-ARCH/build /usr/local/src/linux-headers-"$(uname -r)"; \
    cd /home/darling/build; \
    make lkm -j"$(nproc)"; \
    make lkm_install;

# Copy our entrypoint into the container.
COPY ./docker-assets /

# Setup our environment variables.
ENV PATH="/usr/local/bin:$PATH"

# Drop down to our unprivileged user.
USER darling

# Set our working directory.
WORKDIR /home/darling

# Set the entrypoint.
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Set the default command
CMD ["/bin/bash"]
