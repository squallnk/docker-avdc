FROM lsiobase/alpine:3.10
LABEL maintainer="VergilGao"

# 软件包版本号
ARG GLIBC_VERSION
ARG AVDC_VERSION

RUN \
    cd /tmp && \
    echo "**** install glibc ****" && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk && \
    wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk && \
    apk add glibc-${GLIBC_VERSION}.apk && \
    apk add glibc-bin-${GLIBC_VERSION}.apk && \
    echo "**** install avdc ****" && \
    wget -O avdc.zip https://github.com/yoshiko2/AV_Data_Capture/releases/download/${AVDC_VERSION}/AV_Data_Capture-CLI-${AVDC_VERSION}-linux-amd64.zip && \
    unzip avdc.zip -d /jav &&\
    echo "**** cleanup ****" && \
    rm /etc/apk/keys/sgerrand.rsa.pub && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/* && \
    apk del .build-dependencies

# 镜像版本号
ARG BUILD_DATE
ARG VERSION
LABEL build_version="catfight360.com version:- ${VERSION} build-date:- ${BUILD_DATE}"

COPY root/ /