# syntax=docker/dockerfile:1

FROM --platform=linux/amd64 debian:bookworm-slim AS bundle

COPY Gemfile Gemfile.lock /var/www/letter-avatars/

RUN <<EOF sh -exs
DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade
DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
  build-essential \
  libffi-dev \
  ruby-bundler \
  ruby-dev
cd /var/www/letter-avatars
bundle config set deployment true
bundle install --verbose
EOF


FROM --platform=linux/amd64 debian:bookworm-slim

RUN <<EOF sh -exs
DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade
DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
  imagemagick \
  libcairo2 \
  libfreetype6 \
  libfribidi0 \
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
adduser --quiet --disabled-password --uid 9001 --gecos '' --shell /bin/bash web
DEBIAN_FRONTEND=noninteractive apt-get clean
( find /var/lib/apt/lists -mindepth 1 -delete || true )
( find /var/tmp           -mindepth 1 -delete || true )
( find /tmp               -mindepth 1 -delete || true )
EOF

COPY policy.xml /usr/local/etc/ImageMagick-7/

COPY --from=bundle --chown=9001 /var/www/letter-avatars /var/www/letter-avatars/

COPY --chown=9001 \
     config.ru \
     fonts/NotoSansArabic-Medium.ttf \
     fonts/NotoSansArmenian-Medium.ttf \
     fonts/NotoSansBengali-Medium.ttf \
     fonts/NotoSansDevanagari-Medium.ttf \
     fonts/NotoSansDisplay-Medium.ttf \
     fonts/NotoSansHebrew-Medium.ttf \
     fonts/NotoSansJavanese-Regular.ttf \
     fonts/NotoSansMono-Medium.ttf \
     fonts/NotoSansMonoCJKsc-Regular.otf \
     fonts/NotoSansTelugu-Regular.ttf \
     fonts/NotoSansThai-Medium.ttf \
     fonts/Roboto-Medium \
     unicorn.conf.rb \
     /var/www/letter-avatars/
COPY --chown=9001 lib/ /var/www/letter-avatars/lib/
COPY as-web \
     entrypoint \
     /usr/local/sbin/

ENTRYPOINT ["/usr/local/sbin/entrypoint"]
