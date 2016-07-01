FROM nginx

ADD nginx.conf /etc/nginx/nginx.conf
RUN adduser --uid 9001 --gecos 'Stable nginx UID' --home /usr/share/empty --no-create-home --disabled-password --disabled-login nginx-for-realz
