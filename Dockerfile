FROM vito-docker-private.artifactory.vgt.vito.be/centos8.2:latest

LABEL ESA World Cereal Processing Chain

RUN sed -i 's/enabled=0/enabled=1/' /etc/yum.repos.d/CentOS-PowerTools.repo || true && \
    yum install -y python38-devel gcc-c++ gdal-devel python3-gdal && \
    python3.8 -m pip install -I --upgrade "pip<20.3" && \
    python3.8 -m pip install -v --extra-index-url https://artifactory.vgt.vito.be/api/pypi/python-packages/simple worldcereal>=0.3.2a1 && \
    rm -rf /root/.cache && \
    yum clean all && \
    rm -rf /var/cache/yum/*

ENV GDAL_CACHEMAX 16
ENV LOGURU_FORMAT='<green>{time:YYYY-MM-DD HH:mm:ss.SSS}</green> | <level>{level: <8}</level> | <cyan>{thread}</cyan>:<cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - <level>{message}</level>'
