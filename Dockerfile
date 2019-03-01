FROM debian:stretch as builder
WORKDIR /build
RUN \
  apt-get update; \
  apt-get install -y \
    lsb-release \
    wget; \
  wget -q http://build.openmodelica.org/apt/openmodelica.asc -O- | apt-key add - ; \
  for deb in deb deb-src; do echo "$deb http://build.openmodelica.org/apt `lsb_release -cs` nightly"; done | tee /etc/apt/sources.list.d/openmodelica.list; \
  apt-get update; \
  apt-get build-dep -y openmodelica; \
  apt-get install -y git

RUN \
  git clone https://openmodelica.org/git-readonly/OpenModelica.git; \
  cd OpenModelica; \
  git checkout 220cd16ea23df879cef1e2b32ea19c38f27ce27d; \
  git submodule update --init --recursive \
    libraries \
    OMCompiler \
    common

RUN \
  cd OpenModelica; \
  autoconf; \
  ./configure CC=clang CXX=clang++ --prefix=/; \
  make -j8;

FROM debian:stretch-slim
WORKDIR /
COPY --from=builder /build/OpenModelica/build .
RUN \
  apt-get update; \
  apt-get install -y \
    build-essential \
    clang \
    expat \
    hwloc \
    liblapack3 \
    liblapack-dev \
    libopenblas-base \
    libopenblas-dev \
    libtool \
    liblpsolve55-dev\
    libsundials* \
    wget \
    zip
