FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive
# Set the bash outline
RUN apt update
RUN apt install -y \
  build-essential \
  cargo \
  checksec \
  elfutils \
  file \
  gdb \
  gdbserver \
  git \
  libc6-dbg \
  libglib2.0-dev \
  libssl-dev \
  liblzma-dev \
  netcat \
  patchelf \
  pkg-config \
  python3-dev \
  python3-pip \
  python3-setuptools \
  python3-venv \
  qemu \
  qemu-user-static \
  strace \
  sudo \
  unzip \
  valgrind \
  vim \
  wget \
  xclip

RUN mkdir /chall

RUN useradd -m pwn
RUN chown -R pwn /opt
RUN echo 'pwn ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER pwn

ENV LC_ALL=C.UTF-8

RUN echo 'export PS1="\e[0;35m[\e[0;31mctf\e[0;35m]@\w\n\e[0m~ "' >> /home/pwn/.bashrc
RUN echo 'PATH=$PATH:/home/pwn/.cargo/bin:/home/pwn/.local/bin' >> /home/pwn/.bashrc

COPY ./template/exploit.py /opt/template/exploit.py
ENV EXPLOIT_TEMPLATE=/opt/template/exploit.py

RUN cargo install pwninit
RUN echo "alias pwninit='pwninit --template-path $EXPLOIT_TEMPLATE --template-bin-name elf'" >> /home/pwn/.bashrc

RUN bash -c "$(curl -fsSL https://gef.blah.cat/sh)"

RUN pip install pwntools
RUN pip install z3-solver
RUN pip install requests
RUN pip install pycryptodome

# Helix stuff <3
WORKDIR /opt

RUN git clone https://github.com/SoraTenshi/helix/
WORKDIR /opt/helix
RUN git switch new-daily-driver
RUN git fetch && git pull
RUN cargo install --locked --path helix-term
RUN mkdir /home/pwn/.config/helix -p
RUN ln -Ts /opt/helix/runtime /home/pwn/.config/helix/runtime
RUN /home/pwn/.cargo/bin/hx --grammar fetch && /home/pwn/.cargo/bin/hx --grammar build
COPY ./helix/config.toml /home/pwn/.config/helix/

WORKDIR /chall
RUN chown -R pwn /chall

CMD bash

