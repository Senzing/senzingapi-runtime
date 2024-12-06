# senzingapi-runtime

## :warning: Warning

This repository is specifically for Senzing API V3.
It is not designed to work with Senzing SDK V4.

To find the Senzing API V4 version of this repository, visit [senzingsdk-runtime].

## Synopsis

A Docker image with Senzingapi library installed.

## Overview

The [senzing/senzingapi-runtime] Docker image has the Senzingapi library installed
to simplify creating applications that use the Senzingapi library.

The [senzing/senzingapi-runtime] Docker image is not intended to be run as a container directly.
Rather, it's intention is to be a Docker "base image" that is extended.
As such, the [senzing/senzingapi-runtime] Docker image is a "root container".

## Use

In your `Dockerfile`, set the base image to `senzing/senzingapi-runtime`.
Example:

```Dockerfile
FROM senzing/senzingapi-runtime
```

**Note:** To simplify extending the Docker image,
the `senzing/senzingapi-runtime` image is `USER root`.
As a best practice, the final image should be a non-root user.

To determine which versions of Senzing are being used in local repositories,
run

```console
docker image inspect --format '{{.Config.Labels.SenzingAPI}}  {{.RepoTags}}' $(docker images --filter "label=SenzingAPI" --format "{{.Repository}}:{{.Tag}}") | sort | uniq
```

## License

View [license information] for the software container in this Docker image.
Note that this license does not permit further distribution.

This Docker image may also contain software from the [Senzing GitHub community]
under the [Apache License 2.0].

Further, as with all Docker images, this likely also contains other software which may
be under other licenses (such as Bash, etc. from the base distribution, along with any direct
or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that
any use of this image complies with any relevant licenses for all software contained within.

[Apache License 2.0]: https://www.apache.org/licenses/LICENSE-2.0
[license information]: https://senzing.com/end-user-license-agreement/
[Senzing GitHub community]: https://github.com/Senzing/
[senzing/senzingapi-runtime]: https://hub.docker.com/r/senzing/senzingapi-runtime
[senzingsdk-runtime]: https://github.com/Senzing/senzingsdk-runtime
