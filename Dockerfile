FROM vito-docker-private.artifactory.vgt.vito.be/centos8.2:latest

LABEL ESA World Cereal Processing Chain

RUN sed -i 's/enabled=0/enabled=1/' /etc/yum.repos.d/CentOS-PowerTools.repo || true && \
    yum install -y python38-devel gcc-c++ gdal-devel python3-gdal && \
    pip3 install --extra-index-url https://artifactory.vgt.vito.be/api/pypi/python-packages/simple https://artifactory.vgt.vito.be/python-packages-public-snapshot/worldcereal/0.1.2a1/worldcereal-0.1.2a1.20210521.52_develop-py3-none-any.whl && \
    rm -rf /root/.cache && \
    yum clean all && \
    rm -rf /var/cache/yum/*

ENV GDAL_CACHEMAX 16
ENV LOGURU_FORMAT='<green>{time:YYYY-MM-DD HH:mm:ss.SSS}</green> | <level>{level: <8}</level> | <cyan>{thread}</cyan>:<cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - <level>{message}</level>'
