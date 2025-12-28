# Stage 1: Build the Flutter Web App as root
FROM ghcr.io/cirruslabs/flutter:3.38.3 AS build

ARG DEFAULT_SCREENER_NAME=self
ARG DEFAULT_SCREENER_CONTACT=contact@lapan.com.br
ARG FLAVOR=dockerVps

WORKDIR /app
COPY . /app/

# Set the working directory for the specific app
WORKDIR /app/apps/survey-patient

# Run flutter pub get
RUN flutter pub get

# Build the web application
RUN flutter build web  --dart-define=FLAVOR="$FLAVOR" --dart-define=DEFAULT_SCREENER_NAME="$DEFAULT_SCREENER_NAME" --dart-define=DEFAULT_SCREENER_CONTACT="$DEFAULT_SCREENER_CONTACT"

# Stage 2: Serve with Nginx as non-root
FROM nginx:alpine

# Create a non-root user 'lapan'
RUN addgroup -S lapan && adduser -S -G lapan lapan

# Copy the build artifacts
COPY --from=build /app/apps/survey-patient/build/web /usr/share/nginx/html

# Set permissions for nginx
RUN mkdir -p /var/run && chown -R lapan:lapan /var/cache/nginx /var/log/nginx /etc/nginx/conf.d /usr/share/nginx/html /tmp /var/run

# Expose port 80 and start Nginx
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
