FROM ubuntu:20.04
LABEL maintainer="TBD"
LABEL description="This docker allow to run ewoc_classification chain."

WORKDIR /tmp
ENV LANG=en_US.utf8
SHELL ["/bin/bash", "-c"]

RUN apt-get update -y \
&& DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-missing --no-install-recommends \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    libgdal-dev \
    g++ \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

ARG WORLDCEREAL_CLASSIF_VERSION=0.4.0
ARG EWOC_CLASSIF_VERSION=0.2.1
ARG EWOC_DAG=0.7.0

LABEL EWOC_CLASSIF="${WORLDCEREAL_CLASSIF_VERSION}"
ENV EWOC_CLASSIF_VENV=/opt/ewoc_classif_venv

RUN python3 -m venv ${EWOC_CLASSIF_VENV}
RUN source ${EWOC_CLASSIF_VENV}/bin/activate
RUN ${EWOC_CLASSIF_VENV}/bin/pip install --upgrade pip

COPY worldcereal-${WORLDCEREAL_CLASSIF_VERSION}.tar.gz /tmp
COPY ewoc_classif-${EWOC_CLASSIF_VERSION}.tar.gz /tmp
COPY ewoc_dag-${EWOC_DAG}.tar.gz /tmp

RUN ${EWOC_CLASSIF_VENV}/bin/pip install setuptools --upgrade --no-cache-dir\
    && ${EWOC_CLASSIF_VENV}/bin/pip install pygdal==3.0.4.10 --no-cache-dir\
    && ${EWOC_CLASSIF_VENV}/bin/pip install satio==1.1.5.dev20211123+develop.5 --no-cache-dir \
    --extra-index-url https://artifactory.vgt.vito.be/api/pypi/python-packages/simple\
    && ${EWOC_CLASSIF_VENV}/bin/pip install /tmp/worldcereal-${WORLDCEREAL_CLASSIF_VERSION}.tar.gz --no-cache-dir \
    --extra-index-url https://artifactory.vgt.vito.be/api/pypi/python-packages/simple \
    && ${EWOC_CLASSIF_VENV}/bin/pip install  /tmp/ewoc_dag-${EWOC_DAG}.tar.gz --no-cache-dir\
    && ${EWOC_CLASSIF_VENV}/bin/pip install  /tmp/ewoc_classif-${EWOC_CLASSIF_VERSION}.tar.gz --no-cache-dir

ENV GDAL_CACHEMAX 16
ENV LOGURU_FORMAT='<green>{time:YYYY-MM-DD HH:mm:ss.SSS}</green> | <level>{level: <8}</level> | <cyan>{thread}</cyan>:<cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - <level>{message}</level>'

ARG EWOC_CLASSIF_DOCKER_VERSION='dev'
ENV EWOC_CLASSIF_DOCKER_VERSION=${EWOC_CLASSIF_DOCKER_VERSION}
LABEL version=${EWOC_CLASSIF_DOCKER_VERSION}

ADD entrypoint.sh /opt
RUN chmod +x /opt/entrypoint.sh
ENTRYPOINT [ "/opt/entrypoint.sh" ]
CMD [ "--help" ]
