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

ARG EWOC_CLASSIF_VERSION=0.3.2a1.20210916.256-develop
LABEL EWOC_CLASSIF="${EWOC_CLASSIF_VERSION}"
ENV EWOC_CLASSIF_VENV=/opt/ewoc_classif
RUN python3 -m venv ${EWOC_CLASSIF_VENV}
RUN source ${EWOC_CLASSIF_VENV}/bin/activate
RUN ${EWOC_CLASSIF_VENV}/bin/pip install --upgrade "pip<20.3"
ADD https://artifactory.vgt.vito.be/python-packages/worldcereal/0.3.2a1/worldcereal-0.3.2a1.20210916.256_develop-py3-none-any.whl /tmp
RUN ${EWOC_CLASSIF_VENV}/bin/pip install --no-cache-dir -v --extra-index-url https://artifactory.vgt.vito.be/api/pypi/python-packages/simple /tmp/worldcereal-0.3.2a1.20210916.256_develop-py3-none-any.whl

ENV GDAL_CACHEMAX 16
ENV LOGURU_FORMAT='<green>{time:YYYY-MM-DD HH:mm:ss.SSS}</green> | <level>{level: <8}</level> | <cyan>{thread}</cyan>:<cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - <level>{message}</level>'

ADD entrypoint.sh /opt
RUN chmod +x /opt/entrypoint.sh
ENTRYPOINT [ "/opt/entrypoint.sh" ]
CMD [ "-h" ]
