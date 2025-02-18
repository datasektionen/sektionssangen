FROM debian:latest

RUN apt-get update && apt-get install -y \
    wget \
    gcc \
    apt-utils \
    make \
    && rm -rf /var/lib/apt/lists/*

# Using GNUs Simula compiler cim 5.1
RUN wget https://ftp.gnu.org/gnu/cim/cim-5.1.tar.gz \
    && tar xf cim-5.1.tar.gz

WORKDIR cim-5.1

# Janky shit to make cim compile
RUN find . -type f -name "*.c" -exec sed -i 's|#include "../../lib/cim.h"|#include "cim.h"|' {} \;

RUN ./configure
RUN make
RUN make install
RUN ldconfig /usr/local/lib

WORKDIR /app
COPY . /app
RUN cim -o program song.sim

CMD ["./program"]
