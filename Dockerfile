FROM ubuntu

ARG S6_OVERLAY_VERSION=3.2.0.0
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
  && apt-get install -y \
    ca-certificates \
    curl \
    sudo \
    xz-utils

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

ENV TERM=xterm

RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
  | sh -s -- install linux --init none --no-start-daemon --no-confirm

SHELL ["su", "-l", "-c"]

RUN nix profile install nixpkgs#devenv

ENTRYPOINT ["/init"]
