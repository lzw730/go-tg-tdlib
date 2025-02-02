# 静态编译 tdlib 需要至少3.5GB RAM
FROM scjtqs/tdlib:alpine-base AS builder

RUN cd / \
#   && git clone https://ghproxy.com/https://github.com/scjtqs2/td -b 1.7.10 --depth 1 \
   && git clone  https://ghproxy.com/https://github.com/tdlib/td.git --branch v1.8.0 --depth 1 \
    && cd td \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr/local .. \
#    && cmake --build . -- -j$(($(nproc) + 1)) \
#    && cmake --build .  --target prepare_cross_compiling -j5 \
    && cmake --build .  --target prepare_cross_compiling \
    && cd .. \
    && php SplitSource.php \
    && cd build \
#    && cmake --build . --target install -j4 \
    && cmake --build . --target install \
    && cd .. \
    && php SplitSource.php --undo

FROM alpine:3.15
RUN  sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
COPY --from=builder /usr/local/include/td /usr/local/include/td
COPY --from=builder /usr/local/lib/libtd* /usr/local/lib/
#COPY --from=builder /usr/lib/libssl.a /usr/local/lib/libssl.a
#COPY --from=builder /usr/lib/libcrypto.a /usr/local/lib/libcrypto.a
#COPY --from=builder /lib/libz.a /usr/local/lib/libz.a
# RUN apk update && apk add --no-cache git gcc libc-dev g++ make openssl-dev zlib-dev && rm -rf /var/cache/apk/*

