FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive
# Set the bash outline
RUN apt update
RUN apt install -y \
  build-essential \
  checksec \
  elfutils \
  file \
  gdb \
  gdbserver \
  git \
  libc6-dbg \
  libglib2.0-dev \
  netcat \
  patchelf \
  python3-dev \
  python3-pip \
  python3-setuptools \
  python3-venv \
  qemu \
  qemu-user-static \
  strace \
  sudo \
  valgrind \
  vim \
  wget \
  xclip

RUN useradd -m pwn
RUN chown -R pwn /opt 
RUN echo 'pwn ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER pwn

RUN echo 'export PS1="\e[0;35m[\e[0;31mctf\e[0;35m]@\w\n\e[0m~ "' >> ~/.bashrc

WORKDIR /opt

RUN git clone https://github.com/pwndbg/pwndbg
WORKDIR /opt/pwndbg
ENV LC_ALL=C.UTF-8
RUN ./setup.sh

RUN pip install pwntools
RUN pip install z3-solver
RUN pip install requests
RUN pip install pycryptodome

WORKDIR /chall
CMD bash

