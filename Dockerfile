FROM ubuntu

ARG S6_OVERLAY_VERSION=3.2.0.0
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y \
  && apt install -y \
    ca-certificates \
    curl \
    sudo \
    xz-utils \
    lsb-release \
    gpg-agent \
    software-properties-common \
    build-essential \
  && rm -rf /var/lib/apt/lists/*

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install linux \
  --extra-conf "sandbox = false" \
  --init none \
  --no-confirm

ENV PATH="${PATH}:/nix/var/nix/profiles/default/bin"

RUN nix profile install nixpkgs#devenv

ENV TERM=xterm
ENTRYPOINT ["/init"]
SHELL ["su", "-l", "-c"]
