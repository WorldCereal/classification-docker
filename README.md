# classification-docker
Docker image creation for classification


## Getting started
Logging in to the docker repo:

```docker login vito-docker-private-dev.artifactory.vgt.vito.be```
This is only needed once, and not for public repos.

Pulling the image:

```docker pull vito-docker-private-dev.artifactory.vgt.vito.be/worldcereal:20210520-5```

For testing, you can open a bash shell in the image:

```docker run -it vito-docker-private-dev.artifactory.vgt.vito.be/worldcereal:20210520-5 /bin/bash```

In that shell, you can simply run the 'worldcereal' command.

For reference, most Python packages are installed under:

/usr/local/lib/python3.8/site-packages/

## Direct worldcereal invocation

In a production setup, you'll want to invoke worldcereal immediately. This command also mounts Terrascope data locations:

```docker run docker run -v /data/MEP/DEM/COP-DEM_GLO-30_DTED:/data/MEP/DEM/COP-DEM_GLO-30_DTED:ro -v /data/MTDA/AgERA5:/data/MTDA/AgERA5:ro -v /data/worldcereal/data/s1_sigma0_tiled:/data/worldcereal/data/s1_sigma0_tiled:ro -v /data/MTDA/TERRASCOPE_Sentinel2/TOC_V2:/data/MTDA/TERRASCOPE_Sentinel2/TOC_V2:ro vito-docker-private-dev.artifactory.vgt.vito.be/worldcereal:20210520-9 worldcereal  '["31UFS","50SMF"]' /tmp```

For fast debugging, add the '--debug' flag to process a smaller chunk of data. 