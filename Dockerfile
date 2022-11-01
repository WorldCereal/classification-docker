FROM ubuntu:20.04
LABEL maintainer="TBD"
LABEL description="This docker allow to run ewoc_classification chain."

WORKDIR /tmp
ENV LANG=en_US.utf8
SHELL ["/bin/bash", "-c"]

RUN apt-get update -y \
&& DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common \
&& apt-get update -y \
&& add-apt-repository ppa:ubuntugis/ppa\
&& DEBIAN_FRONTEND=noninteractive apt-get install -y --fix-missing --no-install-recommends \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    libgdal-dev \
    gdal-bin\
    g++ \
    wget\
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

# Add biomes
ENV EWOC_AUXDATA=/auxdata/
RUN mkdir ${EWOC_AUXDATA}  \
    && wget -qO- https://artifactory.vgt.vito.be/auxdata-public/worldcereal/auxdata/biomes.tar.gz | tar xvz -C ${EWOC_AUXDATA}

# Add models from s3

RUN wget -q "https://ewoc-aux-data.s3.eu-central-1.amazonaws.com/models/models_cropland_700_croptype_502_irr_420.tar.gz?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAXJWPWGFXGK4RNF7R%2F20221028%2Feu-central-1%2Fs3%2Faws4_request&X-Amz-Date=20221028T164843Z&X-Amz-Expires=14400&X-Amz-SignedHeaders=host&X-Amz-Signature=bf243895975a2b5a4be949d243b97773d6dd3c5056fb1a29b1ce843ef9a12ac9" -O /tmp/models_cropland_700_croptype_502_irr_420.tar.gz \
    && tar -xzf /tmp/models_cropland_700_croptype_502_irr_420.tar.gz --strip-components 2 -C / \
    && rm /tmp/models_cropland_700_croptype_502_irr_420.tar.gz

ENV EWOC_CLASSIF_VENV=/opt/ewoc_classif_venv
RUN python3 -m venv ${EWOC_CLASSIF_VENV}
RUN source ${EWOC_CLASSIF_VENV}/bin/activate

ENV GDAL_CACHEMAX=2000
ENV LOGURU_FORMAT='<green>{time:YYYY-MM-DD HH:mm:ss.SSS}</green> | <level>{level: <8}</level> | <cyan>{thread}</cyan>:<cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - <level>{message}</level>'

## Limit pip and setuptools version to to avoid issue with rebuild and major upgrade version
RUN ${EWOC_CLASSIF_VENV}/bin/pip install "pip<22" --upgrade --no-cache-dir\
    && ${EWOC_CLASSIF_VENV}/bin/pip install "setuptools<61" --upgrade --no-cache-dir

ARG WORLDCEREAL_CLASSIF_VERSION=1.0.8
COPY worldcereal-${WORLDCEREAL_CLASSIF_VERSION}.tar.gz /tmp
RUN ${EWOC_CLASSIF_VENV}/bin/pip install "pygdal==$(gdal-config --version).*" --no-cache-dir\
    && ${EWOC_CLASSIF_VENV}/bin/pip install /tmp/worldcereal-${WORLDCEREAL_CLASSIF_VERSION}.tar.gz --no-cache-dir --extra-index-url https://artifactory.vgt.vito.be/api/pypi/python-packages/simple

ARG EWOC_CLASSIF_DOCKER_VERSION='0.6.1'
ENV EWOC_CLASSIF_DOCKER_VERSION=${EWOC_CLASSIF_DOCKER_VERSION}
LABEL version=${EWOC_CLASSIF_DOCKER_VERSION}
LABEL EWOC_CLASSIF="${WORLDCEREAL_CLASSIF_VERSION}"

ARG EWOC_CLASSIF_VERSION=0.7.1
ARG EWOC_DAG=0.8.5
COPY ewoc_classif-${EWOC_CLASSIF_VERSION}.tar.gz /tmp
COPY ewoc_dag-${EWOC_DAG}.tar.gz /tmp

RUN ${EWOC_CLASSIF_VENV}/bin/pip install  /tmp/ewoc_dag-${EWOC_DAG}.tar.gz --no-cache-dir\
    && ${EWOC_CLASSIF_VENV}/bin/pip install  /tmp/ewoc_classif-${EWOC_CLASSIF_VERSION}.tar.gz --no-cache-dir\
    && ${EWOC_CLASSIF_VENV}/bin/pip install  boto3 --no-cache-dir\
    && ${EWOC_CLASSIF_VENV}/bin/pip install  psycopg2-binary --no-cache-dir \
    && ${EWOC_CLASSIF_VENV}/bin/pip install  rfc5424-logging-handler --no-cache-dir

ADD entrypoint.sh /opt
RUN chmod +x /opt/entrypoint.sh
ENTRYPOINT [ "/opt/entrypoint.sh" ]
CMD [ "--help" ]
