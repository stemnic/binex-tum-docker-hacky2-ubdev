FROM ubuntu:impish-20210606

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update -y && DEBIAN_FRONTEND="noninteractive" && apt-get install -y -q dialog apt-utils build-essential screen netcat cmake wget gdb htop vim git libssl-dev libffi-dev tmux gdbserver gdb-multiarch zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev curl libbz2-dev python3 python3-dev python3-pip python3-setuptools libc6-dbg glibc-source && rm -rf /var/lib/apt/lists/*

# Locales setup
RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" \
    && apt-get install -y \
        locales \
        tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && locale-gen en_US.UTF-8

RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
    ENV LANG en_US.UTF-8  
    ENV LANGUAGE en_US:en  
    ENV LC_ALL en_US.UTF-8   

RUN echo "export LC_ALL=en_US.UTF-8" >> ~/.bashrc
RUN echo "export PYTHONIOENCODING=UTF-8" >> ~/.bashrc

# ynet daemon
ADD https://yx7.cc/code/ynetd/ynetd-0.1.2.tar.xz /ynetd-0.1.2.tar.xz

RUN tar -xf ynetd-0.1.2.tar.xz

RUN make -C /ynetd-0.1.2/

RUN useradd -m pwn

ADD vuln /home/pwn/vuln
ADD start_server.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start_server.sh

RUN chmod 0755 /home/pwn/vuln

EXPOSE 1337

WORKDIR /home/pwn/

CMD ["/usr/local/bin/start_server.sh"]
