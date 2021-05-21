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

In a production setup, you'll want to invoke worldcereal immediately:

```docker run vito-docker-private-dev.artifactory.vgt.vito.be/worldcereal:20210520-9 worldcereal  '["31UFS","50SMF"]' /tmp```