# Stage 1: Build the Flutter web app
FROM ghcr.io/cirruslabs/flutter:3.38.3 AS build
WORKDIR /app

# Declare build arguments for API base URL
ARG API_BASE_URL

# Copy the app files
COPY . .

# Install dependencies
RUN flutter pub get

# Build the web app, passing the API_BASE_URL as a Dart define
RUN flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL

# Stage 2: Serve the built web app with Nginx
FROM nginx
WORKDIR /usr/share/nginx/html

# Copy the built files from the build stage
COPY --from=build /app/build/web .

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
