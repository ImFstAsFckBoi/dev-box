FROM alpine:latest

VOLUME [ “/sys/fs/cgroup” ]

### Install packages from apk-list.txt
RUN apk update
RUN apk upgrade

COPY ./apk-list.txt /tmp/
RUN apk add $(cat /tmp/apk-list.txt | sed "/#/d" | xargs | tr '\r\n' ' ' | tr '\n' ' ')

# build required packages
RUN apk add zsh curl openrc

### Add dev user
RUN adduser -h /home/dev/ -G wheel -S -s /bin/zsh dev
RUN echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers; exit 0
RUN echo "permit nopass :wheel" >> /etc/doas.d/doas.conf; exit 0
RUN echo "dev:pass" | chpasswd

RUN mkdir -p /run/openrc
RUN echo "" > /run/openrc/softlevel

WORKDIR /home/dev/

COPY ./.gitconfig ./
RUN mkdir .ssh .vscode-server sync
RUN chmod +rw .ssh .vscode-server sync .gitconfig

USER dev
COPY ./run.sh /tmp/
RUN sh /tmp/run.sh
### Set up zsh with oh-my-zsh
RUN sed -i '1,/ZSH_THEME=.*/{s/ZSH_THEME=.*/ZSH_THEME="itchy"/}' ./.zshrc
COPY ./rc-tail.txt /tmp/
RUN cat /tmp/rc-tail.txt >> ./.zshrc

