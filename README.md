# EWoC classification processor - Docker image

Docker image use to run the EWoC classification step

## Build EWoC classification processor docker image

To build the docker image you need to have acess to the following private python packages:

- [worldcereal](https://github.com/WorldCereal/wc-classification)
- [ewoc_dag](https://github.com/WorldCereal/ewoc_dataship)
- [ewoc_classif](https://github.com/WorldCereal/ewoc_classif)

The associated python packages need to be close to the `Dockerfile` file.

You can now run the following command to build the docker image:

```sh
docker build --build-arg EWOC_CLASSIF_DOCKER_VERSION=$(git describe) --pull --rm -f "Dockerfile" -t ewoc_classif:$(git describe) "."
```

## Use EWoC classification processor docker image

### Retrieve EWoC classification processor docker image

```sh
docker login 643vlk6z.gra7.container-registry.ovh.net -u ${harbor_username}
docker pull 643vlk6z.gra7.container-registry.ovh.net/world-cereal/ewoc_classif:${tag_name}
```

### Local usage (outside Argo workflow)

You need to pass to the docker image a file with some credentials with the option `--env-file /path/to/env.file`.

This file must contains the following variables:

- EWOC_S3_ACCESS_KEY_ID
- EWOC_S3_SECRET_ACCESS_KEY

#### Generate a specific S2 tile

To run the generation of a specific S2 tile ID:

:warning: Adapt the `tag_name` to the right one

```sh
docker run --rm --env-file /local/path/to/env.file ewoc_classif:${tag_name} ewoc_classif 36MXB -v
```

For more options please read the [ewoc_classif readme](https://github.com/WorldCereal/ewoc_classif#readme) or run:

```sh
docker run --rm -it ewoc_classif:${tag_name} ewoc_classif --help
```

## How to release

The release of new docker image is made through Github Action to the EWoC docker registry.
When develop is ready and functional, you can merge into main. After you must tag in main branch a new version with `git tag -a tag_name` command with `tag_name` following [semver](https://semver.org/).
