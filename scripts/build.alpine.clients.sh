#!/bin/bash
mkdir base/tools/clients

apk add gcc g++ build-base linux-headers cmake make autoconf automake libtool curl
apk add openssl-dev openssl-libs-static libev-dev pcre-dev libsodium-dev libsodium-static c-ares-dev libevent-dev libevent-static mbedtls-dev mbedtls-static

git clone https://github.com/shadowsocks/simple-obfs
cd simple-obfs
git submodule init
git submodule update
./autogen.sh
./configure --disable-documentation
make -j4
cd src
gcc obfs_local*.o ../libcork/.libs/libcork.a -o simple-obfs -lev -s -static
mv simple-obfs ../../base/tools/clients/
cd ../..

git clone https://github.com/shadowsocks/shadowsocks-libev
cd shadowsocks-libev
git submodule init
git submodule update
./autogen.sh
./configure --disable-documentation
make -j4
cd src
gcc ss_local*.o .libs/libshadowsocks-libev.a -o ss-local -lpcre -lmbedtls -lmbedcrypto -lev -lsodium -s -static
mv ss-local ../../base/tools/clients/
cd ../..

git clone https://github.com/shadowsocksrr/shadowsocksr-libev
cd shadowsocksr-libev
git checkout -b latest origin/Akkariiin/develop
./autogen.sh
./configure --disable-documentation
make -j4
cd src
gcc ss_local*.o .libs/libshadowsocks-libev.a ../libudns/.libs/libudns.a -o ssr-local -lpcre -lssl -lcrypto -lev -lsodium -s -static
mv ssr-local ../../base/tools/clients/
cd ../..

if [[ `uname -m` = "x86_64" ]];then
    curl -LO https://github.com/v2ray/v2ray-core/releases/latest/download/v2ray-linux-64.zip
    curl -LO https://github.com/joewalnes/websocketd/releases/download/v0.3.1/websocketd-0.3.1-linux_amd64.zip
    else if [[ "$ARCH" = "x86" ]];then
        curl -LO https://github.com/v2ray/v2ray-core/releases/latest/download/v2ray-linux-32.zip
        curl -LO https://github.com/joewalnes/websocketd/releases/download/v0.3.1/websocketd-0.3.1-linux_386.zip
    else
        curl -LO https://github.com/joewalnes/websocketd/releases/download/v0.3.1/websocketd-0.3.1-linux_arm.zip
        if [[ "$ARCH" = "aarch64" ]];then
            curl -LO https://github.com/v2ray/v2ray-core/releases/latest/download/v2ray-linux-arm64.zip
            else if [[ "$ARCH" = "armhf" ]];then
                curl -LO https://github.com/v2ray/v2ray-core/releases/latest/download/v2ray-linux-arm.zip
            fi
        fi
    fi
fi

unzip v2ray*.zip v2ray v2ctl
unzip websocketd*.zip websocketd
strip -s websocketd
mv v2ray base/tools/clients/
mv v2ctl base/tools/clients/
mv websocketd base/tools/gui/

chmod +rx base/tools/clients/* base/tools/gui/websocketd
