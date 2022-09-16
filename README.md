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

From OVH harbor
```sh
docker login 643vlk6z.gra7.container-registry.ovh.net -u ${harbor_username}
docker pull 643vlk6z.gra7.container-registry.ovh.net/world-cereal/ewoc_classif:${tag_name}
```
From AWS ECR
```sh
aws ecr get-login-password --region region | docker login --username AWS --password-stdin aws_account_id.dkr.ecr.region.amazonaws.com
docker pull aws_account_id.dkr.ecr.region.amazonaws.com/world-cereal/ewoc_classif:${tag_name}
```
### Local usage (outside Argo workflow)

You need to pass to the docker image a file with some credentials with the option `--env-file /path/to/env.file`.

This file must contain the following variables:

- EWOC_S3_ACCESS_KEY_ID
- EWOC_S3_SECRET_ACCESS_KEY
- EWOC_ENDPOINT_URL
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- EWOC_BLOCKSIZE=1024
- GDAL_CACHEMAX=2000
- AGERA5_BUCKET=ewoc-agera5-yearly
- PRD_BUCKET=ewoc-prd-dev [Optional]
- EWOC_CLOUD_PROVIDER= aws [or creodias]
- EWOC_DEV_MODE=True
- EWOC_REGION_NAME

#### Generate a specific S2 tile

To run the generation of a specific S2 tile ID:

:warning: Adapt the `tag_name` to the right one

Cropland for one block
```sh
docker run --rm --env-file /local/path/to/env.file ewoc_classif:${tag_name} ewoc_classif ewoc_classif <s2 tile id> <production_id> --end-season-year 2021 --model-version v502 --irr-model-version v420 --block-ids 89
```
Summer1
```sh
docker run --rm --env-file /local/path/to/env.file ewoc_classif:${tag_name} ewoc_classif ewoc_classif <s2 tile id> <production_id> --end-season-year 2021 --ewoc-detector croptype --ewoc-season summer1 --model-version v502 --irr-model-version v420 --block-ids 89
```

Post-processing (mosaic)
Cropland mosaic for a s2 tile
```sh
docker run --rm --env-file /local/path/to/env.file ewoc_classif:${tag_name} ewoc_classif ewoc_classif <s2 tile id> <production_id> --end-season-year 2021 --model-version v502 --irr-model-version v420 --postprocess True
```
For more options please read the [ewoc_classif readme](https://github.com/WorldCereal/ewoc_classif#readme) or run:

```sh
docker run --rm -it ewoc_classif:${tag_name} ewoc_classif --help
```

## How to release

The release of new docker image is made through Github Action to the EWoC docker registry.
When develop is ready and functional, you can merge into main. After you must tag in main branch a new version with `git tag -a tag_name` command with `tag_name` following [semver](https://semver.org/).
