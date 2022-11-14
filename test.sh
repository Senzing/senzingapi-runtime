#!/bin/bash

# Check ENV for LD_LIBRARY_PATH
if [[ -z "${LD_LIBRARY_PATH}" ]]; then
  echo "Environment variable LD_LIBRARY_PATH is not set"
  exit 0
else
  MY_SCRIPT_VARIABLE="${DEPLOY_ENV}"

# Verify that some Senzing files have been installed
# /opt/senzing/g2/g2BuildVersion.json  (log contents)
FILE=/opt/senzing/g2/g2BuildVersion.json
if test -f "$FILE"; then
    echo "$FILE exists."
else
    echo "$FILE does not exist."
    exit 0
fi

# /opt/senzing/data/libpostal/data_version
FILE=/opt/senzing/data/libpostal/data_version
if test -f "$FILE"; then
    echo "$FILE exists."
else
    echo "$FILE does not exist."
    exit 0
fi

# parse /opt/senzing/g2/g2BuildVersion.json, get BUILD_VERSION and compare it with SENZING_APT_INSTALL_PACKAGE="senzingapi-runtime=3.3.1-22283"
# {
#     "PLATFORM": "Linux",
#     "VERSION": "3.3.2",
#     "BUILD_VERSION": "3.3.2.22299",
#     "BUILD_NUMBER": "2022_10_26__19_38",
#     "DATA_VERSION": "3.0.0"
# }