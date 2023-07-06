FROM --platform=linux/amd64 debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get dist-upgrade --yes \
    && apt-get install --yes --no-install-recommends \
        # rubygem build deps
        gcc \
        libffi-dev \
        make \
        ruby-dev \
        # runtime deps
        imagemagick \
        libcairo2 \
        libfreetype6 \
        libfribidi0 \
        libglib2.0 \
        libgomp1 \
        libgraphite2-3 \
        libgs-common \
        libharfbuzz0b \
        libicu72 \
        libjemalloc2 \
        libltdl7 \
        libpng16-16 \
        libraqm0 \
        pngquant \
        ruby \
        ruby-bundler \
        tini \
        util-linux

COPY fonts/Roboto-Medium \
        fonts/NotoSansDisplay-Medium.ttf \
        fonts/NotoSansMono-Medium.ttf \
        fonts/NotoSansMonoCJKsc-Regular.otf \
        fonts/NotoSansArabic-Medium.ttf \
        fonts/NotoSansDevanagari-Medium.ttf \
        fonts/NotoSansBengali-Medium.ttf \
        fonts/NotoSansJavanese-Regular.ttf \
        fonts/NotoSansTelugu-Regular.ttf \
        fonts/NotoSansThai-Medium.ttf \
        fonts/NotoSansHebrew-Medium.ttf \
        fonts/NotoSansArmenian-Medium.ttf \
        Gemfile \
        Gemfile.lock \
        config.ru \
        unicorn.conf.rb \
    /var/www/letter-avatars/
COPY lib/ /var/www/letter-avatars/lib/
COPY as-web entrypoint /usr/local/sbin/
COPY policy.xml   /usr/local/etc/ImageMagick-7/

RUN adduser \
      --shell /bin/bash \
      --uid 9001 \
      --gecos '' \
      --disabled-password \
      --quiet \
      web \
    && chown -R web /var/www/letter-avatars \
    && cd /var/www/letter-avatars \
    && as-web bundle config set deployment true \
    && as-web bundle install --verbose \
    && apt-get --yes --purge remove \
      gcc \
      libffi-dev \
      make \
      ruby-dev \
    && apt-get --yes --purge autoremove \
    && apt-get clean \
    && ( find /var/lib/apt/lists -mindepth 1 -delete || true ) \
    && ( find /var/tmp -mindepth 1 -delete || true ) \
    && ( find /tmp -mindepth 1 -delete || true )

ENTRYPOINT ["/usr/local/sbin/entrypoint"]
