FROM nicolaka/netshoot:latest

WORKDIR /app

RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache gost sing-box kcptun

COPY ./network-probe ./network-probe
