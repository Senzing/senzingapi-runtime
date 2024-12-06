ARG BASE_IMAGE=debian:11.11-slim@sha256:00558f781b91e90469812bad32002f311ab26ef241b4a1996f6600680ec82f5c
FROM ${BASE_IMAGE}

# Create the build image.

ARG SENZING_ACCEPT_EULA="I_ACCEPT_THE_SENZING_EULA"
ARG SENZING_APT_INSTALL_PACKAGE="senzingapi-runtime=3.12.0-24261"
ARG SENZING_APT_REPOSITORY_NAME="senzingrepo_2.0.0-1_all.deb"
ARG SENZING_APT_REPOSITORY_URL="https://senzing-production-apt.s3.amazonaws.com"

ENV REFRESHED_AT=2024-09-26

ENV SENZING_ACCEPT_EULA=${SENZING_ACCEPT_EULA} \
    SENZING_APT_INSTALL_PACKAGE=${SENZING_APT_INSTALL_PACKAGE} \
    SENZING_APT_REPOSITORY_NAME=${SENZING_APT_REPOSITORY_NAME} \
    SENZING_APT_REPOSITORY_URL=${SENZING_APT_REPOSITORY_URL}

LABEL Name="senzing/senzingapi-runtime" \
      Maintainer="support@senzing.com" \
      Version="3.12.0" \
      SenzingAPI="3.12.0"

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

HEALTHCHECK CMD apt list --installed | grep senzingapi-runtime

# Set environment variables for root.

ENV LD_LIBRARY_PATH=/opt/senzing/g2/lib

# Runtime execution.

WORKDIR /
CMD ["/bin/bash"]
