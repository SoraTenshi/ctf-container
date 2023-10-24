FROM --platform=linux/amd64 ubuntu:20.04

ENV DEBIAN_FRONTEND noninteractive
# Set the bash outline
RUN apt update --fix-missing
RUN apt install -y \
  build-essential \
  checksec \
  clang-format \
  clang-tidy \
  clang-tools \
  clang \
  clangd \
  curl \
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

RUN curl -sSf https://sh.rustup.rs | bash -s -- -y
ENV PATH="/home/pwn/.cargo/bin:${PATH}"

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
RUN pip install python-lsp-server

# Helix stuff <3
WORKDIR /opt

RUN git clone https://github.com/SoraTenshi/helix/
WORKDIR /opt/helix
RUN git switch new-daily-driver
RUN git fetch && git pull
RUN HELIX_DISABLE_AUTO_GRAMMAR_BUILD='1' cargo install --locked --path helix-term
RUN mkdir /home/pwn/.config/helix -p
RUN ln -Ts /opt/helix/runtime /home/pwn/.config/helix/runtime
COPY ./helix/config.toml /home/pwn/.config/helix/
# For now, let's just build the grammar manually
# RUN hx --grammar fetch && hx --grammar build

WORKDIR /chall
RUN sudo chown -R pwn /chall

CMD bash

