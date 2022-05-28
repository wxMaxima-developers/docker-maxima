# If we start with a more recent debian version we depend on a glibc that is at
# least as new as the one shipped with this version excluding users of
# debian-oldstable
FROM ubuntu:trusty
#FROM debian:oldstable

ARG ARCH=x86_64

RUN apt-get update && apt-get -q -y install git autoconf python binutils \
    texinfo gcc libtool vim desktop-file-utils pkgconf libcairo2-dev \
    libssl-dev libfuse-dev zsync wget fuse bzip2 gawk g++ gperf \
    libgtk-3-dev doxygen libatspi2.0-dev

# Debian-oldstable provides a sbcl. But as sbcl is evolving rapidly we want to use
# a more recent version.
RUN wget --quiet 'http://prdownloads.sourceforge.net/sbcl/sbcl-1.4.16-x86-64-linux-binary.tar.bz2' -O /tmp/sbcl.tar.bz2 && \
    mkdir /sbcl && \
    tar jxf /tmp/sbcl.tar.bz2 --strip-components=1 -C /sbcl && \
    cd /sbcl && \
    sh install.sh && \
    rm -f /tmp/sbcl.tar.bz2

RUN git clone https://git.code.sf.net/p/gnuplot/gnuplot-main && \
    cd gnuplot-main && \
    git checkout tags/5.2.8
RUN cd gnuplot-main && \
    ./prepare && \
    ./configure --prefix=`pwd`/dist && \
    make -s && \
    make install

ENV maxima_build tags/5.46.0

RUN git clone https://git.code.sf.net/p/maxima/code maxima-code && \
    cd maxima-code && \
    git checkout ${maxima_build}

RUN cd maxima-code && \
    mkdir dist && \
    ./bootstrap && \
    ./configure --enable-sbcl-exec --enable-quiet-build --prefix=`pwd`/dist && \
    make -s && \
    make install


COPY appimagetool-$ARCH.AppImage /
RUN chmod +x appimagetool-$ARCH.AppImage
RUN ./appimagetool-$ARCH.AppImage --appimage-extract && \
    cp -R squashfs-root/* .

RUN mkdir maxima-squashfs
WORKDIR maxima-squashfs
RUN mkdir -p usr/bin

RUN cp -ar /gnuplot-main/dist gnuplot-inst
RUN ln -s ../../gnuplot-inst/bin/gnuplot usr/bin/gnuplot

RUN (cd .. && tar cf - sbcl) | tar xf -
RUN ln -s ../../sbcl/run-sbcl.sh usr/bin/sbcl

RUN mkdir maxima-inst && \
    (cd ../maxima-code/dist && tar cf - *) | (cd maxima-inst && tar xf -)
RUN ln -s share/info maxima-inst/info
RUN ln -s ../../maxima-inst/bin/maxima usr/bin/maxima

RUN mkdir -p usr/share/metainfo
COPY maxima.appdata.xml usr/share/metainfo/

COPY AppRun .
RUN chmod +x AppRun
COPY maxima.desktop .
COPY maxima.png .

WORKDIR /
RUN ARCH=$ARCH appimagetool maxima-squashfs
