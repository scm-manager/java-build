#
# Copyright (c) 2020 - present Cloudogu GmbH
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see https://www.gnu.org/licenses/.
#
FROM eclipse-temurin:25.0.3_9-jdk

ENV DOCKER_VERSION=29.6.1 \
    DOCKER_CHANNEL=stable \
    DOCKER_CHECKSUM=b0df4a43a98d7ecb708acbdb5a34a3416e13b6e39bcbbdf296f51f0f3442b29f \
    BUILDX_VERSION=0.35.0\
    BUILDX_CHECKSUM=d41ece72044243b4f58b343441ae37446d9c29a7d6b5e11c61847bbcf8f7dfda

# fake modprobe
COPY modprobe.sh /usr/local/bin/modprobe

# install required packages
RUN set -eux; \
 apt-get update \
 && apt-get install --no-install-recommends -y \
    # mercurial is requried for integration tests of the scm-hg-plugin
    mercurial \
    git \
    curl \
    libgtk-3-0 \
    libnotify-dev \
    libgbm-dev \
    libnss3 \
    libxss1 \
    libasound2t64 \
    libxtst6 \
    xauth \
    xvfb \
 # download docker
 && curl -o docker-${DOCKER_VERSION}.tgz https://download.docker.com/linux/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.tgz \
 && echo "${DOCKER_CHECKSUM} docker-${DOCKER_VERSION}.tgz" > docker-${DOCKER_VERSION}.sha256sum \
 && sha256sum -c docker-${DOCKER_VERSION}.sha256sum \
 # download buildx
 && mkdir -p /usr/local/lib/docker/cli-plugins \
 && curl -L -o docker-buildx https://github.com/docker/buildx/releases/download/v${BUILDX_VERSION}/buildx-v${BUILDX_VERSION}.linux-amd64 \
 && echo "${BUILDX_CHECKSUM} docker-buildx" > docker-buildx.sha256sum \
 && sha256sum -c docker-buildx.sha256sum \
 && mv docker-buildx /usr/local/lib/docker/cli-plugins/ \
 && chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx \
 # extract docker and install it to /usr/local/bin
 && tar --extract \
    		--file docker-${DOCKER_VERSION}.tgz \
    		--strip-components 1 \
    		--directory /usr/local/bin/ \
 # verify docker installation
 && docker --version \
 # remove temporary files
 && rm -f docker-${DOCKER_VERSION}.tgz docker-${DOCKER_VERSION}.sha256sum docker-buildx.sha256sum \
 # clear apt caching
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 # create jenkins passwd entry, because some commands fail if there is no entry for the uid
 # we create user and groups which mach our ci environment
 && groupadd -g 988 docker \
 && groupadd -g 1002 jenkins \
 && useradd -u 1002 -g 1002 -G 988 -s /bin/bash -m jenkins
