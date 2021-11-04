# EWoC classification processor - Docker image

Docker image use to run the EWoC classification step

## Build EWoC classification processor docker image

To build the docker image you need to have the following private python packages close to the Dockerfile:

- worldcereal

You can now run the following command to build the docker image:

```sh
docker build --build-arg EWOC_CLASSIF_DOCKER_VERSION=$(git describe) --pull --rm -f "Dockerfile" -t ewoc_classif:$(git describe) "."
```

## Use EWoC classification processor docker image

### Retrieve EWoC classification processor docker image

```sh
docker login hfjcmwgl.gra5.container-registry.ovh.net -u ${harbor_username}
docker pull hfjcmwgl.gra5.container-registry.ovh.net/world-cereal/ewoc_classif:${tag_name}
```

### Local usage (outside Argo workflow)

You need to pass to the docker image a file with some credentials with the option `--env-file /path/to/env.file`.

This file contains the following variables (TBC):

- EWOC_S3_ACCESS_KEY_ID
- EWOC_S3_SECRET_ACCESS_KEY

#### Generate a specific S2 tile

To run the generation of a specific S2 tile ID:

:warning: Adapt the `tag_name` to the right one

```sh
docker run -v /path/to/conf_dir:/data --rm --env-file /local/path/to/env.file ewoc_classif:${tag_name} 36MXB /data/config.json /tmp 
```

For more option cf. worldcereal documenation or run:

```sh
docker run --rm -it ewoc_classif:${tag_name}
```

## How to release

The release of new docker image is made through Github Action to the EWoC docker registry.
When develop is ready and functional, you can merge into main. After you must tag in main branch a new version with `git tag -a tag_name` command with `tag_name` following [semver](https://semver.org/).