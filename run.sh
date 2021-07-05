#!/bin/bash

#docker run -it --privileged -v $(pwd):/home/pwn --privileged --cap-add=SYS_PTRACE -p 127.0.0.1:1337:1337 stemnic/binex-hacky2-ubdev:latest
docker run -it -p 127.0.0.1:1337:1337 stemnic/binex-hacky2-ubdev:challange
