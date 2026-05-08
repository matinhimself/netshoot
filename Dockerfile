FROM ubuntu:latest

USER root
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y kcptun

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
    python3-venv

RUN mkdir -p /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN GOST_VERSION=$(curl -s https://api.github.com/repos/go-gost/gost/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//') && \
    wget https://github.com/go-gost/gost/releases/download/v${GOST_VERSION}/gost_${GOST_VERSION}_linux_amd64.tar.gz && \
    tar -zxvf gost_${GOST_VERSION}_linux_amd64.tar.gz && \
    mv gost /usr/local/bin/gost && \
    chmod +x /usr/local/bin/gost && \
    rm gost_${GOST_VERSION}_linux_amd64.tar.gz

# Replace your existing sing-box RUN command with this:
RUN ARCH=$(dpkg --print-architecture) && \
    SB_VERSION=$(curl -s https://api.github.com/repos/SagerNet/sing-box/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//') && \
    wget https://github.com/SagerNet/sing-box/releases/download/v${SB_VERSION}/sing-box-${SB_VERSION}-linux-${ARCH}.tar.gz && \
    tar -zxvf sing-box-${SB_VERSION}-linux-${ARCH}.tar.gz && \
    # The tar creates a folder, we find the binary inside and move it
    mv sing-box-*/sing-box /usr/local/bin/sing-box && \
    chmod +x /usr/local/bin/sing-box && \
    rm -rf sing-box-*

WORKDIR /root

ENV WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go
ENV WG_SUDO=1
RUN apt install -y --no-install-recommends wireguard-go wireguard-tools

# --- NEW: Install paqet from latest GitHub releases ---
RUN ARCH=$(dpkg --print-architecture) && \
    PAQET_TAG=$(curl -s https://api.github.com/repos/hanselime/paqet/releases/latest | grep tag_name | cut -d '"' -f 4) && \
    wget "https://github.com/hanselime/paqet/releases/download/${PAQET_TAG}/paqet-linux-${ARCH}-${PAQET_TAG}.tar.gz" && \
    tar -zxvf paqet-linux-${ARCH}-${PAQET_TAG}.tar.gz && \
    mv paqet_linux_${ARCH} /usr/local/bin/paqet && \
    chmod +x /usr/local/bin/paqet && \
    rm paqet-linux-${ARCH}-${PAQET_TAG}.tar.gz

# Install FRP (Fast Reverse Proxy)
RUN ARCH=$(dpkg --print-architecture) && \
    FRP_VERSION=$(curl -s https://api.github.com/repos/fatedier/frp/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//') && \
    wget https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_${ARCH}.tar.gz && \
    tar -zxvf frp_${FRP_VERSION}_linux_${ARCH}.tar.gz && \
    mv frp_${FRP_VERSION}_linux_${ARCH}/frpc /usr/local/bin/frpc && \
    mv frp_${FRP_VERSION}_linux_${ARCH}/frps /usr/local/bin/frps && \
    chmod +x /usr/local/bin/frpc /usr/local/bin/frps && \
    rm -rf frp_${FRP_VERSION}_linux_${ARCH}*

RUN mkdir -p /etc/frp /etc/sing-box

# Verification layer
RUN sing-box version && \
    gost -V && \
    python3 --version && \
    kcptun-server --version && \
    nginx -v && \
    wg -v && \
    paqet version && \
    frpc --version

COPY ./network-probe ./network-probe
COPY ./configs/frpc.toml /etc/frp/frpc.toml
COPY ./configs/sing-box.json /etc/sing-box/config.json

CMD ["/bin/bash"]

