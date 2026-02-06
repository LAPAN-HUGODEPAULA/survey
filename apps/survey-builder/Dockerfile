# Stage 1: Build the Flutter Web App as root
FROM ghcr.io/cirruslabs/flutter:3.38.3 AS build

ARG API_BASE_URL=/api/v1

WORKDIR /app
COPY . /app/

WORKDIR /app/apps/survey-builder

RUN flutter pub get
RUN flutter build web --dart-define=FLAVOR="dockerVps" --dart-define=API_BASE_URL="$API_BASE_URL"

# Stage 2: Serve with Nginx as non-root
FROM nginx:alpine

RUN addgroup -S lapan && adduser -S -G lapan lapan

COPY --from=build /app/apps/survey-builder/build/web /usr/share/nginx/html

RUN mkdir -p /var/run && chown -R lapan:lapan /var/cache/nginx /var/log/nginx /etc/nginx/conf.d /usr/share/nginx/html /tmp /var/run

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
