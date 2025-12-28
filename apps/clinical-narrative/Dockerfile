# Stage 1: Build the Flutter web app as root
FROM ghcr.io/cirruslabs/flutter:3.38.3 AS build

ARG API_BASE_URL

WORKDIR /app
COPY . /app/

# Set the working directory for the specific app
WORKDIR /app/apps/clinical-narrative

# Run flutter pub get
RUN flutter pub get

# Build the web application
RUN flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL

# Stage 2: Serve the built web app with Nginx as non-root
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# Create a non-root user 'lapan'
RUN addgroup -S lapan && adduser -S -G lapan lapan

# Copy the built files from the build stage
COPY --from=build /app/apps/clinical-narrative/build/web .

# Set permissions for nginx
RUN mkdir -p /var/run && chown -R lapan:lapan /var/cache/nginx /var/log/nginx /etc/nginx/conf.d /usr/share/nginx/html /tmp /var/run

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
