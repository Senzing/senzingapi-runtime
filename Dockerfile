ARG BASE_IMAGE=debian:13.2-slim@sha256:e711a7b30ec1261130d0a121050b4ed81d7fb28aeabcf4ea0c7876d4e9f5aca2
FROM ${BASE_IMAGE}

# Create the build image.

ARG SENZING_ACCEPT_EULA="I_ACCEPT_THE_SENZING_EULA"
ARG SENZING_APT_INSTALL_PACKAGE="senzingapi-runtime=3.13.0-25273"
ARG SENZING_APT_REPOSITORY_NAME="senzingrepo_2.0.1-1_all.deb"
ARG SENZING_APT_REPOSITORY_URL="https://senzing-production-apt.s3.amazonaws.com"

ENV REFRESHED_AT=2025-06-20

ENV SENZING_ACCEPT_EULA=${SENZING_ACCEPT_EULA} \
    SENZING_APT_INSTALL_PACKAGE=${SENZING_APT_INSTALL_PACKAGE} \
    SENZING_APT_REPOSITORY_NAME=${SENZING_APT_REPOSITORY_NAME} \
    SENZING_APT_REPOSITORY_URL=${SENZING_APT_REPOSITORY_URL}

LABEL Name="senzing/senzingapi-runtime" \
      Maintainer="support@senzing.com" \
      Version="3.13.0" \
      SenzingAPI="3.13.0"

# Run as "root" for system installation.

USER root

# Eliminate warning messages.

ENV TERM=xterm

# Install packages via apt.

RUN apt-get update \
 && apt-get -y --no-install-recommends install \
        ca-certificates \
        wget

# Install Senzing repository index and package.

RUN wget -O \
        /${SENZING_APT_REPOSITORY_NAME} \
        ${SENZING_APT_REPOSITORY_URL}/${SENZING_APT_REPOSITORY_NAME} \
  && apt-get -y --no-install-recommends install \
        /${SENZING_APT_REPOSITORY_NAME} \
  && apt-get update \
  && rm /${SENZING_APT_REPOSITORY_NAME} \
  && apt-get -y --no-install-recommends install \
        libpq5 \
        ${SENZING_APT_INSTALL_PACKAGE} \
        jq \
  && apt-get clean

HEALTHCHECK CMD apt list --installed | grep senzingapi-runtime

# Set environment variables for root.

ENV LD_LIBRARY_PATH=/opt/senzing/g2/lib

# Runtime execution.

WORKDIR /
CMD ["/bin/bash"]