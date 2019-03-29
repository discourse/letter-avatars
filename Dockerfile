FROM ruby:2.6.2-alpine

ENV PREFIX /usr/local

RUN apk add \
	autoconf \
	automake \
	build-base \
	bzip2-dev \
	freetype \
	freetype-dev \
	ghostscript \
	ghostscript-dev \
	ghostscript-fonts \
	git \
	libbz2 \
	libgcc \
	libgomp \
	libjpeg-turbo \
	libjpeg-turbo-dev \
	libltdl \
	libtool \
	linux-headers \
	sudo \
	tiff \
	tiff-dev \
	tini \
	xz \
	xz-dev \
	xz-libs

RUN mkdir /tmp/jemalloc	\
	&& cd /tmp/jemalloc \
	&& wget https://github.com/jemalloc/jemalloc/releases/download/3.6.0/jemalloc-3.6.0.tar.bz2 \
	&& tar -xjf jemalloc-3.6.0.tar.bz2 && cd jemalloc-3.6.0 \
	&& ./configure \
	&& make -j \
	&& mv lib/libjemalloc.so.1 /usr/lib \
	&& rm -rf /tmp/jemalloc

ENV LIBPNG_VERSION 1.6.36
RUN mkdir /tmp/libpng \
	&& wget http://prdownloads.sourceforge.net/libpng/libpng-$LIBPNG_VERSION.tar.gz?downlolad -O /tmp/libpng/libpng.tar.gz \
	&& cd /tmp/libpng \
	&& tar -xzvf /tmp/libpng/libpng.tar.gz \
	&& cd libpng-$LIBPNG_VERSION \
	&& ./configure --prefix=$PREFIX \
	&& make all && make install \
	&& rm -rf /tmp/libpng

ENV IMAGEMAGICK_VERSION 7.0.8-35
RUN mkdir /tmp/imagemagick \
	&& cd /tmp/imagemagick \
	&& wget -O ImageMagick.tar.gz "https://imagemagick.org/download/ImageMagick-$IMAGEMAGICK_VERSION.tar.gz" \
	&& tar zxf ImageMagick.tar.gz \
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
	&& rm -rf /tmp/imagemagick

ADD policy.xml /usr/local/etc/ImageMagick-7/

ADD Gemfile /var/www/letter-avatars/Gemfile
ADD Gemfile.lock /var/www/letter-avatars/Gemfile.lock
ADD Roboto-Medium /var/www/letter-avatars/Roboto-Medium
ADD NotoSansMono-Medium.ttf /var/www/letter-avatars/NotoSansMono-Medium.ttf
ADD NotoSansMonoCJKsc-Regular.otf /var/www/letter-avatars/NotoSansMonoCJKsc-Regular.otf
ADD NotoSansArabic-Medium.ttf /var/www/letter-avatars/NotoSansArabic-Medium.ttf
ADD NotoSansDevanagari-Medium.ttf /var/www/letter-avatars/NotoSansDevanagari-Medium.ttf
ADD NotoSansBengali-Medium.ttf /var/www/letter-avatars/NotoSansBengali-Medium.ttf
ADD NotoSansJavanese-Regular.ttf /var/www/letter-avatars/NotoSansJavanese-Regular.ttf
ADD NotoSansTelugu-Regular.ttf /var/www/letter-avatars/NotoSansTelugu-Regular.ttf

RUN adduser -s /bin/bash -u 9001 -D web \
	&& cd /var/www/letter-avatars \
	&& chown -R web . \
	&& sudo -E -u web bundle install --deployment --verbose

ADD config.ru /var/www/letter-avatars/config.ru
ADD lib /var/www/letter-avatars/lib
ADD unicorn.conf.rb /var/www/letter-avatars/unicorn.conf.rb

RUN apk del \
	autoconf \
	automake \
	build-base \
	bzip2-dev \
	freetype-dev \
	ghostscript \
	ghostscript-dev \
	git \
	libjpeg-turbo-dev \
	libtool \
	tiff-dev \
	xz \
	xz-dev \
	&& rm -rf /var/cache/apk/*

ENTRYPOINT ["/sbin/tini", "--", "sudo", "-E", "-u", "web", "/bin/sh", "-c", "cd /var/www/letter-avatars && exec bundle exec unicorn -E production -c /var/www/letter-avatars/unicorn.conf.rb"]
