FROM ubuntu:latest

USER root
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    vim \
    nano \
    ca-certificates \
    gnupg \
    procps \
    git \
    iputils-ping \
    net-tools \
    iproute2 \
    netcat-openbsd \
    telnet \
    nmap \
    iperf3 \
    mtr-tiny \
    traceroute \
    tcpdump \
    dnsutils \
    socat \
    openssh-client \
    openssh-server \
    nginx \
    python3 \
    python3-pip \
    python3-venv \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN KCP_VERSION=$(curl -s https://api.github.com/repos/xtaci/kcptun/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//') && \
    wget https://github.com/xtaci/kcptun/releases/download/v${KCP_VERSION}/kcptun-linux-amd64-${KCP_VERSION}.tar.gz && \
    tar -zxvf kcptun-linux-amd64-${KCP_VERSION}.tar.gz -C /usr/local/bin/ && \
    rm kcptun-linux-amd64-${KCP_VERSION}.tar.gz

RUN GOST_VERSION=$(curl -s https://api.github.com/repos/go-gost/gost/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//') && \
    wget https://github.com/go-gost/gost/releases/download/v${GOST_VERSION}/gost_${GOST_VERSION}_linux_amd64.tar.gz && \
    tar -zxvf gost_${GOST_VERSION}_linux_amd64.tar.gz && \
    mv gost /usr/local/bin/gost && \
    chmod +x /usr/local/bin/gost && \
    rm gost_${GOST_VERSION}_linux_amd64.tar.gz

RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://sing-box.app/gpg.key | gpg --dearmor -o /etc/apt/keyrings/sagernet.gpg && \
    chmod a+r /etc/apt/keyrings/sagernet.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/sagernet.gpg] https://deb.sagernet.org/ * *" \
    > /etc/apt/sources.list.d/sagernet.list && \
    apt-get update && \
    apt-get install -y sing-box

WORKDIR /root

RUN sing-box version && \
    gost -V && \
    python3 --version && \
    nginx -v

COPY ./network-probe ./network-probe

CMD ["/bin/bash"]
