FROM ubuntu:impish-20210606

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update -y && DEBIAN_FRONTEND="noninteractive" && apt-get install -y -q dialog apt-utils build-essential screen netcat cmake wget gdb htop vim git libssl-dev libffi-dev tmux gdbserver gdb-multiarch zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev curl libbz2-dev python3 python3-dev python3-pip python3-setuptools libc6-dbg glibc-source && rm -rf /var/lib/apt/lists/*

#RUN curl -O https://www.python.org/ftp/python/3.9.5/Python-3.9.5.tar.xz
#RUN tar -xf Python-3.9.5.tar.xz
#RUN cd Python-3.9.5 \
#    && ./configure --enable-optimizations \
#    && make -j 12 \
#    && make altinstall

RUN cd /usr/src/glibc \
    && tar xvf glibc-2.33.tar.xz

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

RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install --upgrade ipython

RUN python3 -m pip install --upgrade ropper \
    && DSTDIR=/opt \
    && cd ${DSTDIR} \
    && git clone https://github.com/pwndbg/pwndbg \
    && cd pwndbg \
    && ./setup.sh

# Peda (default disabled)
RUN DSTDIR=/opt \
    && cd ${DSTDIR} \
    && git clone https://github.com/longld/peda.git ${DSTDIR}/peda \
    && echo "# source ${DSTDIR}/peda/peda.py" >> ~/.gdbinit

# Gef (default disabled)
RUN python3 -m pip install --upgrade keystone-engine \
    && DSTDIR=/opt \
    && mkdir -p ${DSTDIR}/gef \
    && wget -O "${DSTDIR}/gef/gdbinit-gef.py" -q "https://github.com/hugsy/gef/raw/master/gef.py" \
    && echo "# source ${DSTDIR}/gef/gdbinit-gef.py" >> ~/.gdbinit

# Pwntools
RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install --upgrade pwntools

RUN echo "export LC_ALL=en_US.UTF-8" >> ~/.bashrc
RUN echo "export PYTHONIOENCODING=UTF-8" >> ~/.bashrc

# Angr for symbolic execution
RUN python3 -m pip install --upgrade angr

RUN echo "dir /usr/src/glibc/glibc-2.33/malloc/" >> ~/.gdbinit

# ynet daemon
ADD https://yx7.cc/code/ynetd/ynetd-0.1.2.tar.xz /ynetd-0.1.2.tar.xz

RUN tar -xf ynetd-0.1.2.tar.xz

RUN make -C /ynetd-0.1.2/

RUN useradd -m pwn

#ADD vuln /home/pwn/vuln
ADD start_server.sh /usr/local/bin/
ADD init.sh /usr/local/bin/
ADD banner /root/.banner
RUN chmod +x /usr/local/bin/start_server.sh
RUN chmod +x /usr/local/bin/init.sh
RUN echo 'export PS1="\n\[\e[01;33m\]\u\[\e[0m\]\[\e[00;37m\]@\[\e[0m\]\[\e[01;36m\]\h\[\e[0m\]\[\e[00;37m\] \[\e[0m\]\[\e[01;35m\]\w\[\e[0m\]\[\e[01;37m\] \[\e[0m\]\n$ "' >> ~/.bashrc
#RUN chmod 0755 /home/pwn/vuln

EXPOSE 1337

WORKDIR /home/pwn/

CMD ["/usr/local/bin/init.sh"]
