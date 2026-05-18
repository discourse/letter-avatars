# syntax=docker/dockerfile:1

FROM nginx:1.30.1-alpine3.23

RUN <<'EOF' sh -exs
apk --no-progress --no-cache upgrade

adduser \
  --uid 9001 \
  --gecos 'Stable nginx UID' \
  --home /usr/share/empty \
  --no-create-home \
  --disabled-password \
  nginx-for-realz
EOF

COPY nginx.conf            /etc/nginx/nginx.conf
COPY default.conf.template /etc/nginx/templates/default.conf.template
COPY nginx-override.conf   /etc/nginx/conf.d/letter-avatars-http-ctx.conf
