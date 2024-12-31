FROM debian:latest

RUN apt-get update && apt-get install -y \
  ca-certificates \
  build-essential \
  curl \
  musl-dev \
  musl-tools \
  make \
  xutils-dev \
  automake \
  autoconf \
  libtool \
  g++ \
  gcc-arm-linux-gnueabi

# Install rust using rustup
RUN curl -k "https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init" -o rustup-init && \
    chmod +x rustup-init && \
    ./rustup-init -y --profile minimal && \
    rm rustup-init

ENV PATH=/usr/local/bin:/root/.cargo/bin:$PATH \
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig \
    LD_LIBRARY_PATH=$PREFIX
RUN rustup target add armv5te-unknown-linux-musleabi
RUN cargo install cargo-deb 

# This musl section copied from rust-embedded/cross, see musl.sh for license
COPY musl.sh /
RUN /musl.sh \
    TARGET=arm-linux-musleabi \
    "COMMON_CONFIG += --with-arch=armv5te \
                      --with-float=soft \
                      --with-mode=arm"

RUN echo "[build]\ntarget = \"armv5te-unknown-linux-musleabi\"" > ~/.cargo/config
RUN echo "[target.armv5te-unknown-linux-musleabi]\nlinker = \"arm-linux-musleabi-gcc\"\nstrip = { path = \"arm-linux-musleabi-strip\" }" > ~/.cargo/config
WORKDIR /volume
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

