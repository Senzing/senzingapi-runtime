ARG BASE_IMAGE=debian:11.9-slim@sha256:0e75382930ceb533e2f438071307708e79dc86d9b8e433cc6dd1a96872f2651d
FROM ${BASE_IMAGE}

# Create the build image.

ARG SENZING_ACCEPT_EULA="I_ACCEPT_THE_SENZING_EULA"
ARG SENZING_APT_INSTALL_PACKAGE="senzingapi-runtime=3.10.1-24135"
ARG SENZING_APT_REPOSITORY_NAME="senzingrepo_2.0.0-1_all.deb"
ARG SENZING_APT_REPOSITORY_URL="https://senzing-production-apt.s3.amazonaws.com"

ENV REFRESHED_AT=2024-05-21

ENV SENZING_ACCEPT_EULA=${SENZING_ACCEPT_EULA} \
  SENZING_APT_INSTALL_PACKAGE=${SENZING_APT_INSTALL_PACKAGE} \
  SENZING_APT_REPOSITORY_NAME=${SENZING_APT_REPOSITORY_NAME} \
  SENZING_APT_REPOSITORY_URL=${SENZING_APT_REPOSITORY_URL}

LABEL Name="senzing/senzingapi-runtime" \
  Maintainer="support@senzing.com" \
  Version="3.10.1" \
  SenzingAPI="3.10.1"

# Run as "root" for system installation.

USER root

# Eliminate warning messages.

ENV TERM=xterm

# Install packages via apt.

RUN apt-get update \
  && apt-get -y install \
  wget

# Install Senzing repository index.

RUN wget -qO \
  /${SENZING_APT_REPOSITORY_NAME} \
  ${SENZING_APT_REPOSITORY_URL}/${SENZING_APT_REPOSITORY_NAME} \
  && apt-get -y install \
  /${SENZING_APT_REPOSITORY_NAME} \
  && apt-get update \
  && rm /${SENZING_APT_REPOSITORY_NAME}

# Install Senzing package.

RUN apt-get -y install \
  libpq5 \
  ${SENZING_APT_INSTALL_PACKAGE} \
  jq \
  && apt-get clean

# Set environment variables for root.

ENV LD_LIBRARY_PATH=/opt/senzing/g2/lib

# Runtime execution.

WORKDIR /
CMD ["/bin/bash"]
