# Stage 1: Build the Flutter Web App as root
FROM ghcr.io/cirruslabs/flutter:3.38.3 AS build

ARG API_BASE_URL=/api/v1

WORKDIR /app
COPY . /app/

# Set the working directory for the specific app
WORKDIR /app/apps/survey-frontend

# Run flutter pub get
RUN flutter pub get

# Build the web application
RUN flutter build web --dart-define=FLAVOR="dockerVps" --dart-define=API_BASE_URL="$API_BASE_URL"

# Stage 2: Serve with Nginx as non-root
FROM nginx:alpine

# Create a non-root user 'lapan'
RUN addgroup -S lapan && adduser -S -G lapan lapan

# Copy the build artifacts
COPY --from=build /app/apps/survey-frontend/build/web /usr/share/nginx/html

# Set permissions for nginx
RUN mkdir -p /var/run && chown -R lapan:lapan /var/cache/nginx /var/log/nginx /etc/nginx/conf.d /usr/share/nginx/html /tmp /var/run

# Expose port 80 and start Nginx
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
