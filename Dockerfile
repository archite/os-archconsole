FROM archlinux/base

ARG COUNTRY=US
ARG LOCALE=en_US.UTF-8
ARG TZ=US/Pacific

RUN pacman -Syu --noconfirm base-devel
RUN pacman -Syu --noconfirm bash
RUN pacman -Syu --noconfirm bash-completion
RUN pacman -Syu --noconfirm ca-certificates
RUN pacman -Syu --noconfirm curl
RUN pacman -Syu --noconfirm git
RUN pacman -Syu --noconfirm htop
RUN pacman -Syu --noconfirm inetutils
RUN pacman -Syu --noconfirm iproute2
RUN pacman -Syu --noconfirm iptables
RUN pacman -Syu --noconfirm kmod
RUN pacman -Syu --noconfirm less
RUN pacman -Syu --noconfirm openssh
RUN pacman -Syu --noconfirm pacman-contrib
RUN pacman -Syu --noconfirm psmisc
RUN pacman -Syu --noconfirm rsync
RUN pacman -Syu --noconfirm sudo
RUN pacman -Syu --noconfirm util-linux
RUN pacman -Syu --noconfirm vim
RUN pacman -Syu --noconfirm zsh
RUN pacman -Syu --noconfirm zsh-completions

RUN rm -rf /etc/ssh/*key*

RUN groupadd -g 1100 rancher
RUN groupadd -g 1101 docker
RUN groupadd -r sudo
RUN useradd -u 1100 -g rancher -G sudo -s /usr/bin/zsh rancher
RUN usermod -aG docker rancher
RUN useradd -u 1101 -g docker -G sudo -s /usr/bin/zsh docker
RUN usermod -aG docker docker
RUN sed -i 's/rancher:!/rancher:*/g' /etc/shadow
RUN sed -i 's/docker:!/docker:*/g' /etc/shadow
RUN echo ClientAliveInterval 180 >> /etc/ssh/sshd_config
RUN echo '## allow password less for rancher user' >> /etc/sudoers
RUN echo 'rancher ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN echo '## allow password less for docker user' >> /etc/sudoers
RUN echo 'docker ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
RUN echo 'ssh-keygen -A' >> /usr/sbin/update-ssh-keys
RUN ln -sfr /usr/bin/vim /usr/bin/vi
RUN echo "LANG=${LOCALE}" > /etc/locale.conf
RUN sed -i "s/^#${LOCALE}/${LOCALE}/" /etc/locale.gen
RUN locale-gen
RUN ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime
RUN curl -s "https://www.archlinux.org/mirrorlist/?country=${COUNTRY}&protocol=http&protocol=https&ip_version=4" | sed 's/^#Server/Server/g' | \
    rankmirrors -n 5 - | tee /etc/pacman.d/mirrorlist

ENTRYPOINT ["/usr/bin/ros", "entrypoint"]
