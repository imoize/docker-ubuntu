# Ubuntu-s6 Docker Image

Custom image based on ubuntu with s6-overlay. 

[![Github Build Status](https://img.shields.io/github/actions/workflow/status/imoize/docker-ubuntu/build.yml?color=458837&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=build&logo=github)](https://github.com/imoize/docker-ubuntu/actions?workflow=build)
[![GitHub](https://img.shields.io/static/v1.svg?color=3C79F5&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=imoize&message=GitHub&logo=github)](https://github.com/imoize/docker-ubuntu)
[![GitHub Package Repository](https://img.shields.io/static/v1.svg?color=3C79F5&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=imoize&message=GitHub%20Package&logo=github)](https://github.com/imoize/docker-ubuntu/pkgs/container/ubuntu-s6)
[![Docker Pulls](https://img.shields.io/docker/pulls/imoize/ubuntu-s6.svg?color=3C79F5&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=pulls&logo=docker)](https://hub.docker.com/r/imoize/ubuntu-s6)

## Supported Architectures

Multi-platform available trough docker manifest. More information is available from docker [here](https://github.com/docker/distribution/blob/master/docs/spec/manifest-v2-2.md#manifest-list).

Simply pulling using `latest` tag should retrieve the correct image for your arch.

The architectures supported by this image:

| Architecture | Available |
| :----: | :----: |
| x86-64 | ✅ |
| arm64 | ✅ |

## Usage

Here are some example to help you get started creating a container, easiest way to setup is using docker-compose or use docker cli.

- **docker-compose (recommended)**

```yaml
---
version: "3.9"
services:
  ubuntu:
    image: imoize/ubuntu-s6:latest
    container_name: ubuntu
    environment:
      - PUID=1001
      - PGID=1001
      - TZ=Asia/Jakarta
    restart: always
```

- **docker cli**

```bash
docker run -d \
  --name=ubuntu \
  -e PUID=1001 \
  -e PGID=1001 \
  -e TZ=Asia/Jakarta \
  --restart always \
  imoize/ubuntu-s6:latest
```
## Available environment variables:

| Name                      | Description                                            | Default Value |
| ------------------------- | ------------------------------------------------------ | ------------- |
| PUID                      | User UID                                               |               |
| PGID                      | Group GID                                              |               |
| TZ                        | Specify a timezone see this [list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List).       | UTC          |
| S6_VERBOSITY              | Controls the verbosity of s6-rc. See [this.](https://github.com/just-containers/s6-overlay?tab=readme-ov-file#customizing-s6-overlay-behaviour)    | 1             |

## Configuration

### Environment variables

When you start the ubuntu-s6 image, you can adjust the configuration of the instance by passing one or more environment variables either on the `docker-compose` file or on the `docker run` command line. Please note that some variables are only considered when the container is started for the first time. If you want to add a new environment variable:

- **for `docker-compose` add the variable name and value:**

```yaml
ubuntu-s6:
    ...
    environment:
    - PUID=1001
    ...
```

- **for manual execution add a `-e` option with each variable and value:**

```bash
  docker run -d \
  -e PUID=1001 \
  imoize/ubuntu-s6:latest
```
## User / Group Identifiers

For example: `PUID=1001` and `PGID=1001`, to find yours user `id` and `gid` type `id <your_username>` in terminal.
```bash
  $ id your_username
    uid=1001(user) gid=1001(group) groups=1001(group)
```

## Tips / Info

* Shell access whilst the container is running:
```console
docker exec -it ubuntu /bin/bash
```
* To monitor the logs of the container in realtime:
```console
docker logs -f ubuntu
```
* Container version number:
```console
docker inspect -f '{{ index .Config.Labels "build_version" }}' ubuntu
```
* Image version number:
```console
docker inspect -f '{{ index .Config.Labels "build_version" }}' imoize/ubuntu-s6:latest
```

## Upgrade this image

We recommend that you follow these steps to upgrade your container.

#### Step 1: Get the updated image

```console
docker pull imoize/ubuntu-s6:latest
```

or if you're using Docker Compose, update the value of the image property to
`imoize/ubuntu-s6:latest`.

#### Step 2: Stop currently running container

Stop the currently running container using this command.

```console
docker stop ubuntu
```

or using Docker Compose:

```console
docker-compose stop ubuntu
```

#### Step 3: Remove currently running container

Remove the currently running container using this command.

```console
docker rm -v ubuntu
```

or using Docker Compose:

```console
docker-compose rm -v ubuntu
```

#### Step 4: Run the new image

Re-create your container from the new image.

```console
docker run --name ubuntu imoize/ubuntu-s6:latest
```

or using Docker Compose:

```console
docker-compose up -d ubuntu
```

#### Step 5: Remove the old dangling images

You can also remove the old dangling images.

```console
docker image prune
```

## Contributing

We'd love for you to contribute to this container. You can submitting a [pull request](https://github.com/imoize/docker-ubuntu/pulls) with your contribution.

## Issues

If you encountered a problem running this container, you can create an [issue](https://github.com/imoize/docker-ubuntu/issues).