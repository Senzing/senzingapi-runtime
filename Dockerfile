ARG BASE_IMAGE=debian:11.3-slim@sha256:f6957458017ec31c4e325a76f39d6323c4c21b0e31572efa006baa927a160891
FROM ${BASE_IMAGE} as builder

# -----------------------------------------------------------------------------
# Stage: Builder
# -----------------------------------------------------------------------------

# Create the runtime image.

ARG SENZING_ACCEPT_EULA="I_ACCEPT_THE_SENZING_EULA"
ARG SENZING_APT_INSTALL_PACKAGE="senzingapi-runtime=3.1.2-22194"
ARG SENZING_APT_REPOSITORY_NAME="senzingrepo_1.0.0-1_amd64.deb"
ARG SENZING_APT_REPOSITORY_URL="https://senzing-production-apt.s3.amazonaws.com"

ENV REFRESHED_AT=2022-07-14

LABEL Name="senzing/senzingapi-runtime" \
      Maintainer="support@senzing.com" \
      Version="3.1.1"

# Run as "root" for system installation.

USER root

# Eliminate warning messages.

ENV TERM=xterm

# Install packages via apt.

RUN apt update \
 && apt -y install \
        curl \
        gnupg \
        wget

# Install Senzing repository index.

RUN curl \
        --output /${SENZING_APT_REPOSITORY_NAME} \
        ${SENZING_APT_REPOSITORY_URL}/${SENZING_APT_REPOSITORY_NAME} \
 && apt -y install \
        /${SENZING_APT_REPOSITORY_NAME} \
 && apt update

# Install Senzing package.

RUN apt -y install ${SENZING_APT_INSTALL_PACKAGE}

# -----------------------------------------------------------------------------
# Stage: Final
# -----------------------------------------------------------------------------

FROM ${BASE_IMAGE} AS runner

# Copy files from builder.

COPY --from=builder /opt/senzing      /opt/senzing
COPY --from=builder /etc/opt/senzing  /etc/opt/senzing

# Set environment variables for root.

ENV LD_LIBRARY_PATH=/opt/senzing/g2/lib

# Runtime execution.

WORKDIR /
CMD ["/bin/bash"]
