FROM emscripten/emsdk:latest

WORKDIR /root

# # Install basic build tools
RUN apt-get update && apt-get install -y build-essential cmake git python3-markdown \
    libgmp3-dev libprocps-dev libboost-all-dev pkg-config
    #libssl-dev

# Download and extract precompiled OpenSSL for WebAssembly
RUN git clone https://github.com/jedisct1/openssl-wasm.git && \
    mkdir -p /usr/local/include/openssl && \
    cp -r openssl-wasm/precompiled/include/openssl /usr/local/include && \
    cp openssl-wasm/precompiled/lib/*.a /usr/lib/x86_64-linux-gnu/


#RUN ls /usr/local/include/openssl && ls /usr/lib/x86_64-linux-gnu/ 
# # Build and install GMP for WebAssembly
# RUN git clone https://github.com/alisw/GMP.git && cd GMP && \
#     emconfigure ./configure --disable-assembly --host none --enable-static --disable-shared && \
#     emmake make && emmake make install
#
# # Build and install Boost for WebAssembly
# RUN wget https://boostorg.jfrog.io/artifactory/main/release/1.76.0/source/boost_1_76_0.tar.gz && \
#     tar xzf boost_1_76_0.tar.gz && cd boost_1_76_0 && \
#     ./bootstrap.sh && \
#     ./b2 toolset=emscripten link=static threading=single runtime-link=static
#
# # Build and install zlib for WebAssembly
# RUN git clone https://github.com/madler/zlib.git && cd zlib && \
#     emconfigure ./configure --static && \
#     emmake make && emmake make install

# Clone and build libsnark
RUN git clone https://github.com/Quantaindew/libsnark-wasm/ && cd libsnark && \
    git checkout wasm-backed && git submodule init && git submodule update && \
    mkdir build && cd build && \
    emcmake cmake .. \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -DNO_PROCPS=1 \
      -DNO_GTEST=1 \
      -DNO_DOCS=1 \
      -DCURVE=ALT_BN128 \
      -DFEATUREFLAGS="-DBINARY_OUTPUT=1 -DMONTGOMERY_OUTPUT=1 -DNO_PT_COMPRESSION=1" \
      -DGMP_INCLUDES=/usr/local/include \
      -DGMP_LIBRARIES=/usr/local/lib/libgmp.a \
      -DOPENSSL_INCLUDES=/usr/local/include \
      -DOPENSSL_LIBRARIES="/usr/local/lib/libcrypto.a;/usr/local/lib/libssl.a" \
      -DBOOST_ROOT=/root/boost_1_76_0 \
      -DZLIB_ROOT=/usr/local && \
    emmake make && \
    emmake make install

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
