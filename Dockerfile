FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    container=docker

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      systemd systemd-sysv dbus \
      bash-completion less vim-tiny nano tmux \
      coreutils findutils grep sed gawk diffutils bc file tree jq \
      procps psmisc lsof iproute2 netcat-openbsd strace \
      shellcheck curl ca-certificates gnupg tzdata \
 && install -d -m 0755 /etc/apt/keyrings \
 && curl -fsSL https://repo.charm.sh/apt/gpg.key | gpg --dearmor -o /etc/apt/keyrings/charm.gpg \
 && echo 'deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *' > /etc/apt/sources.list.d/charm.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends glow \
 && rm -rf /var/lib/apt/lists/* \
 && ln -s /opt/kata/box/bin/kata /usr/local/bin/kata \
 && echo '[ -r /opt/kata/box/profile.sh ] && . /opt/kata/box/profile.sh' >> /root/.bashrc

# systemd expects this signal to shut down cleanly
STOPSIGNAL SIGRTMIN+3
WORKDIR /root/kata
CMD ["/sbin/init"]
