FROM nginx:alpine
RUN addgroup -S lapan && adduser -S -G lapan lapan
COPY apps/clinical-narrative/build/web /usr/share/nginx/html
RUN mkdir -p /var/run && chown -R lapan:lapan /var/cache/nginx /var/log/nginx /etc/nginx/conf.d /usr/share/nginx/html /tmp /var/run
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
