FROM ruby:2.2-alpine

ENV PREFIX /usr/local

RUN apk add --update --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ tini \
	&& rm -rf /var/cache/apk/*

ENV PNGOUT_VERSION pngout-20150319-linux-static
RUN mkdir /tmp/pngout \
	&& cd /tmp/pngout \
	&& wget -O pngout.tgz http://static.jonof.id.au/dl/kenutils/$PNGOUT_VERSION.tar.gz \
	&& tar -xzf pngout.tgz \
	&& mv $PNGOUT_VERSION/i686/pngout-static /usr/bin/pngout \
	&& rm -rf /tmp/pngout

RUN mkdir /tmp/jemalloc	\
	&& cd /tmp/jemalloc \
	&& wget http://www.canonware.com/download/jemalloc/jemalloc-3.6.0.tar.bz2 \
	&& tar -xjf jemalloc-3.6.0.tar.bz2 && cd jemalloc-3.6.0 \
	&& apk update \
	&& apk add build-base \
	&& ./configure \
	&& make -j \
	&& mv lib/libjemalloc.so.1 /usr/lib \
	&& apk del build-base \
	&& rm -rf /var/cache/apk/* /tmp/jemalloc

RUN build_deps="git build-base autoconf automake libtool" \
	&& apk update \
	&& apk add $build_deps \
	&& git clone -b v1.6.19 git://git.code.sf.net/p/libpng/code /tmp/libpng \
	&& cd /tmp/libpng \
	&& ./autogen.sh \
	&& ./configure --prefix=$PREFIX \
	&& make -j all \
	&& make install \
	&& apk del $build_deps \
	&& rm -rf /var/cache/apk/* /tmp/libpng

ENV IMAGEMAGICK_VERSION 6.9.3-10
RUN build_deps="build-base libtool freetype-dev xz xz-dev bzip2-dev tiff-dev libjpeg-turbo-dev ghostscript ghostscript-dev" \
	&& apk update \
	&& apk add $build_deps \
	&& mkdir /tmp/imagemagick \
	&& cd /tmp/imagemagick \
	&& wget -O ImageMagick.tar.xz "http://www.imagemagick.org/download/releases/ImageMagick-${IMAGEMAGICK_VERSION}.tar.xz" \
	&& xz -cd ImageMagick.tar.xz | tar -xf - \
	&& cd ImageMagick-${IMAGEMAGICK_VERSION} \
	&& LDFLAGS=-L$PREFIX/lib CFLAGS=-I$PREFIX/include ./configure \
	   --prefix=$PREFIX \
	   --enable-static \
	   --enable-bounds-checking \
	   --enable-hdri \
	   --enable-hugepages \
	   --with-threads \
	   --with-modules \
	   --with-quantum-depth=16 \
	   --without-magick-plus-plus \
	   --with-bzlib \
	   --with-zlib \
	   --with-gslib \
	   --with-gs-font-dir=/usr/share/fonts/Type1 \
	   --without-autotrace \
	   --with-freetype \
	   --with-jpeg \
	   --without-lcms \
	   --with-lzma \
	   --with-png \
	   --with-tiff \
	&& make -j all \
	&& make -j install \
	&& apk del $build_deps \
	&& apk add freetype xz-libs libbz2 libgcc libgomp libltdl tiff libjpeg-turbo ghostscript-fonts \
	&& rm -rf /var/cache/apk/* /tmp/imagemagick

ADD policy.xml /usr/local/etc/ImageMagick-6/

RUN apk update \
	&& apk add git sudo build-base \
	&& adduser -s /bin/bash -u 9001 -D web \
	&& mkdir -p /var/www \
	&& cd /var/www \
	&& git clone --depth 1 https://github.com/discourse/letter-avatars.git \
	&& cd /var/www/letter-avatars \
	&& chown -R web . \
	&& sudo -E -u web bundle install --deployment --verbose \
	&& sudo -E -u web bundle exec rake \
	&& apk del git build-base \
	&& rm -rf /var/cache/apk/*

ENTRYPOINT ["/usr/bin/tini", "--", "sudo", "-E", "-u", "web", "/bin/sh", "-c", "cd /var/www/letter-avatars && exec bundle exec puma -p 8080 -e production"]
