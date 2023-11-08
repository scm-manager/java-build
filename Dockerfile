#
# MIT License
#
# Copyright (c) 2020-present Cloudogu GmbH and Contributors
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
FROM eclipse-temurin:17.0.9_9-jdk

ENV DOCKER_VERSION=20.10.14 \
    DOCKER_CHANNEL=stable \
    DOCKER_CHECKSUM=7ca4aeeed86619909ae584ce3405da3766d495f98904ffbd9d859add26b83af5\
    BUILDX_VERSION=0.8.2\
    BUILDX_CHECKSUM=c64de4f3c30f7a73ff9db637660c7aa0f00234368105b0a09fa8e24eebe910c3

# fake modprobe
COPY modprobe.sh /usr/local/bin/modprobe

# install required packages
RUN set -eux; \
 apt-get update \
 && apt-get install --no-install-recommends -y \
    # mercurial is requried for integration tests of the scm-hg-plugin
    mercurial \
    # git is required by yarn install of scm-ui
    git \
    # the following dependencies are required for cypress tests and are copied from
    # https://github.com/cypress-io/cypress-docker-images/blob/master/base/12.18.3/Dockerfile
    libgtk2.0-0 \
    libgtk-3-0 \
    libnotify-dev \
    libgconf-2-4 \
    libgbm-dev \
    libnss3 \
    libxss1 \
    libasound2 \
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
 && groupadd -g 998 docker \
 && groupadd -g 1002 jenkins \
 && useradd -u 1001 -g 1002 -G 998 -s /bin/bash -m jenkins
