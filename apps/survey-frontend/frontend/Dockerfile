# Stage 1: Build the Flutter Web App
FROM ghcr.io/cirruslabs/flutter:3.38.3 AS build

WORKDIR /app

# Copy the project files
COPY . .

# Get dependencies
RUN flutter pub get

# Build the web application with the build arguments
RUN flutter build web  --dart-define=FLAVOR="dockerVps" 

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy the build artifacts from the build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
