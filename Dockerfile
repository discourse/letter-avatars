FROM ruby:2.6.3-alpine as builder

ENV PREFIX /usr/local

# Runtime dependencies
RUN apk add \
    cairo \
    freetype \
    fribidi \
    glib \
    graphite2 \
    icu-libs \
    libbz2 \
    libgcc \
    libltdl \
    libgomp \
    pngquant \
    sudo \
    tini

# Build dependencies
RUN apk add \
    autoconf \
    automake \
    build-base \
    bzip2-dev \
    cairo-dev \
    fribidi-dev \
    freetype-dev \
    ghostscript-dev \
    glib-dev \
    gobject-introspection-dev \
    graphite2-dev \
    icu-dev \
    libtool

ENV JEMALLOC_VERSION 3.6.0
RUN mkdir /tmp/jemalloc \
    && cd /tmp/jemalloc \
    && wget -O jemalloc.tar.bz2 https://github.com/jemalloc/jemalloc/releases/download/$JEMALLOC_VERSION/jemalloc-$JEMALLOC_VERSION.tar.bz2 \
    && tar xjf jemalloc.tar.bz2 \
    && cd jemalloc-$JEMALLOC_VERSION \
    && ./configure \
    && make -j \
    && mv lib/libjemalloc.so.1 /usr/lib \
    && rm -rf /tmp/jemalloc

ENV HARFBUZZ_VERSION 2.4.0
RUN mkdir /tmp/harfbuzz \
    && cd /tmp/harfbuzz \
    && wget -O harfbuzz.tar.bz2 https://www.freedesktop.org/software/harfbuzz/release/harfbuzz-$HARFBUZZ_VERSION.tar.bz2 \
    && tar xjf harfbuzz.tar.bz2 \
    && cd harfbuzz-$HARFBUZZ_VERSION \
    && ./configure \
        --prefix=$PREFIX \
        --with-glib \
        --with-gobject \
        --with-graphite2 \
        --with-icu \
    && make -j all \
    && make -j install \
    && rm -rf /tmp/harfbuzz

ENV RAQM_VERSION 0.5.0
RUN mkdir /tmp/raqm \
    && cd /tmp/raqm \
    && wget -O raqm.tar.gz https://github.com/HOST-Oman/libraqm/releases/download/v$RAQM_VERSION/raqm-$RAQM_VERSION.tar.gz \
    && tar xzf raqm.tar.gz \
    && cd raqm-$RAQM_VERSION \
    && ./configure --prefix=$PREFIX \
    && make -j all \
    && make -j install \
    && rm -rf /tmp/raqm

ENV LIBPNG_VERSION 1.6.37
RUN mkdir /tmp/libpng \
    && cd /tmp/libpng \
    && wget -O libpng.tar.gz https://prdownloads.sourceforge.net/libpng/libpng-$LIBPNG_VERSION.tar.gz?downlolad \
    && tar xzf libpng.tar.gz \
    && cd libpng-$LIBPNG_VERSION \
    && ./configure --prefix=$PREFIX \
    && make -j all \
    && make -j install \
    && rm -rf /tmp/libpng

ENV IMAGE_MAGICK_VERSION 7.0.8-42
RUN mkdir /tmp/imagemagick \
    && cd /tmp/imagemagick \
    && wget -O ImageMagick.tar.gz https://github.com/ImageMagick/ImageMagick/archive/$IMAGE_MAGICK_VERSION.tar.gz \
    && tar xzf ImageMagick.tar.gz \
    && cd ImageMagick-${IMAGE_MAGICK_VERSION} \
    && ./configure \
        --prefix=$PREFIX \
        --enable-static \
        --enable-bounds-checking \
        --enable-hugepages \
        --with-modules \
        --without-magick-plus-plus \
    && make -j all \
    && make -j install \
    && rm -rf /tmp/imagemagick

ADD policy.xml /usr/local/etc/ImageMagick-7/

ADD Gemfile /var/www/letter-avatars/Gemfile
ADD Gemfile.lock /var/www/letter-avatars/Gemfile.lock
ADD fonts/Roboto-Medium /var/www/letter-avatars/Roboto-Medium
ADD fonts/NotoSansDisplay-Medium.ttf /var/www/letter-avatars/NotoSansDisplay-Medium.ttf
ADD fonts/NotoSansMono-Medium.ttf /var/www/letter-avatars/NotoSansMono-Medium.ttf
ADD fonts/NotoSansMonoCJKsc-Regular.otf /var/www/letter-avatars/NotoSansMonoCJKsc-Regular.otf
ADD fonts/NotoSansArabic-Medium.ttf /var/www/letter-avatars/NotoSansArabic-Medium.ttf
ADD fonts/NotoSansDevanagari-Medium.ttf /var/www/letter-avatars/NotoSansDevanagari-Medium.ttf
ADD fonts/NotoSansBengali-Medium.ttf /var/www/letter-avatars/NotoSansBengali-Medium.ttf
ADD fonts/NotoSansJavanese-Regular.ttf /var/www/letter-avatars/NotoSansJavanese-Regular.ttf
ADD fonts/NotoSansTelugu-Regular.ttf /var/www/letter-avatars/NotoSansTelugu-Regular.ttf
ADD fonts/NotoSansThai-Medium.ttf /var/www/letter-avatars/NotoSansThai-Medium.ttf
ADD fonts/NotoSansHebrew-Medium.ttf /var/www/letter-avatars/NotoSansHebrew-Medium.ttf
ADD fonts/NotoSansArmenian-Medium.ttf /var/www/letter-avatars/NotoSansArmenian-Medium.ttf

RUN adduser -s /bin/bash -u 9001 -D web \
    && cd /var/www/letter-avatars \
    && chown -R web . \
    && sudo -E -u web bundle install --deployment --verbose

RUN apk del \
    autoconf \
    automake \
    build-base \
    bzip2-dev \
    cairo-dev \
    fribidi-dev \
    freetype-dev \
    ghostscript-dev \
    glib-dev \
    gobject-introspection-dev \
    graphite2-dev \
    icu-dev \
    libtool \
    && rm -rf /var/cache/apk/*

FROM builder

ADD config.ru /var/www/letter-avatars/config.ru
ADD lib /var/www/letter-avatars/lib
ADD unicorn.conf.rb /var/www/letter-avatars/unicorn.conf.rb

ENTRYPOINT ["/sbin/tini", "--", "sudo", "-E", "-u", "web", "/bin/sh", "-c", "cd /var/www/letter-avatars && exec bundle exec unicorn -E production -c /var/www/letter-avatars/unicorn.conf.rb"]
