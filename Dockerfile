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

RUN wget "https://ewoc-aux-data.s3.eu-central-1.amazonaws.com/models/models_cropland_700_croptype_502_irr_420.tar.gz?response-content-disposition=inline&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEEcaCWV1LXdlc3QtMyJGMEQCIEeIhb9%2FqodeNHYc%2B%2BaK7%2FvbcUM3HBz3s6BxxcIahRLPAiAlQgG1JL69J6CSyWeHPzqBwXG%2BXfx%2BdTCaPdUGN%2Fy6UircAggwEAAaDDUwMTg3Mjk5NjcxOCIM2hIXl3ugzFDBX0ApKrkCMPQIAdzhyfNeWycjVChlIgu0VI00DF2zykL5nYgOI92n1XUve8I8b5qecdV4BvIBe%2Bl%2Blw5hVsByEzmntOGNJ4U9oqqv%2B8sAy0OSSfl2ZhJqeTO3lcRtfrA%2FKRKMCbvs9EnAy04d%2Fz%2BVYJ3Y3GCU19%2BBFPIroF6Iwu7WeSL49T%2FlQ%2BU3sUleAleqwJbKm8C5cKKfN%2FmYqI56xvp%2Ff%2BtzRuBem2VgIiAe%2BJzgS%2BtxcSrXBRSb1GXEEPpBC7ktYXB7AIyOAnG11lw59uLVLqhf81WfkXI3sodwpsSyfX%2BpVDHAhwcOyDF1OdSxirQB0MYUJLMu%2BY5%2FcGOxWAdOmKHqgDCKKZJ4Uf%2F7rqqLF18NNOqMUaaQIy5qwL9p0uGiKEsQP76WmRvV7D6f03%2F3DFf%2BbOQ8hmlZXPXpMTC31%2B%2BaBjqIAkPPI74dK1oyD1GlZliam61GZg2J%2BXha%2FE5r5FrQLQtNdMG5vwno6%2F4ix6d%2FGQCIfoApjr6b6vvktmMh704EkwP6nPEG7oKlhBuikmAWW5RMlvNPfYu3ns8BoPutEc9SNga%2FsbDdd8prao2dHiJdosmu%2B1olODwHH3Oxjd1nsK7tm6xyn57ybX7legx27NGHJYUG9ceyr6otgOAAqEZOY3WlFbjTmss%2FLouH6NCmcO%2BX4mEWdL7Bl0fn7xg8FHl3JdJO6H6WdmIUyyYmo0%2FIiCWHjkOQfMTIlnob17Hn7sV4DH%2BsJ6Mncf8RxJEm%2FE9BBgHpCvYBAH9wQmqS3c9AE66HXyoVSZvZPg%3D%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20221028T145921Z&X-Amz-SignedHeaders=host&X-Amz-Expires=43200&X-Amz-Credential=ASIAXJWPWGFXH4LSVBXL%2F20221028%2Feu-central-1%2Fs3%2Faws4_request&X-Amz-Signature=c862b33d32f9151d5de8ad449ac02ef02abefa2361c86a9b1f0b847b98c7be5e" -O /tmp/models_cropland_700_croptype_502_irr_420.tar.gz  \
    && tar -xzf /tmp/models_cropland_700_croptype_502_irr_420.tar.gz --strip-components 1 -C / && rm /tmp/models_cropland_700_croptype_502_irr_420.tar.gz

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

ARG EWOC_CLASSIF_DOCKER_VERSION='0.5.0'
ENV EWOC_CLASSIF_DOCKER_VERSION=${EWOC_CLASSIF_DOCKER_VERSION}
LABEL version=${EWOC_CLASSIF_DOCKER_VERSION}
LABEL EWOC_CLASSIF="${WORLDCEREAL_CLASSIF_VERSION}"

ARG EWOC_CLASSIF_VERSION=0.6.4
ARG EWOC_DAG=0.8.4
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