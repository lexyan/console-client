FROM debian:bullseye as builder

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install git cmake zlib1g-dev libboost-system-dev libboost-program-options-dev libpthread-stubs0-dev libfuse-dev libudev-dev fuse devscripts build-essential lintian debhelper

WORKDIR /workspace
RUN git clone https://github.com/jmcomby/console-client.git
RUN cd ./console-client/pCloudCC/lib/pclsync/ && make fs
RUN cd ./console-client/pCloudCC/lib/mbedtls/ && cmake . && make
RUN cd ./console-client/pCloudCC && cmake . && make && debuild -i -us -uc -b

FROM debian:bullseye-slim

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install fuse libfuse2 libgcc-s1 libstdc++6 libudev1 zlib1g libc6

WORKDIR /root
COPY --from=builder /workspace/console-client/pcloudcc_2.0.1-1_amd64.deb ./
RUN export DEBIAN_FRONTEND=noninteractive \
    && dpkg -i /root/pcloudcc_2.0.1-1_amd64.deb

CMD ["pcloudcc", "-e"]