FROM --platform=linux/amd64 nginx:1.25.1-alpine3.17

COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf.template /etc/nginx/templates/default.conf.template
COPY nginx-override.conf /etc/nginx/conf.d/letter-avatars-http-ctx.conf

RUN adduser --uid 9001 --gecos 'Stable nginx UID' --home /usr/share/empty --no-create-home --disabled-password nginx-for-realz
