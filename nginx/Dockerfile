FROM nginx:1.19

COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf.template /etc/nginx/templates/default.conf.template
COPY nginx-override.conf /etc/nginx/conf.d/letter-avatars-http-ctx.conf

RUN adduser --uid 9001 --gecos 'Stable nginx UID' --home /usr/share/empty --no-create-home --disabled-password --disabled-login nginx-for-realz
