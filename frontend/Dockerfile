# # Multi-stage build for React frontend
# FROM node:20-alpine3.21 as build

# # Update system packages and explicitly upgrade libxml2 to fix CVE-2025-32414 and CVE-2025-32415
# RUN apk update && \
#     apk upgrade && \
#     apk add --upgrade libxml2

# # Set working directory
# WORKDIR /app

# # Copy package files
# COPY package*.json ./

# # Install dependencies
# RUN npm install --omit=dev

# # Copy source code
# COPY . .

# # Build the application
# RUN npm run build

# # Production stage
# FROM nginx:alpine as production

# # Update nginx base image packages for security
# RUN apk update && apk upgrade

# # Copy custom nginx configuration
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# # Copy built application from build stage
# COPY --from=build /app/build /usr/share/nginx/html

# # Create nginx user and set permissions
# RUN chown -R nginx:nginx /usr/share/nginx/html && \
#     chmod -R 755 /usr/share/nginx/html

# # Expose port
# EXPOSE 80

# # Health check
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#     CMD curl -f http://localhost/ || exit 1

# # Start nginx
# CMD ["nginx", "-g", "daemon off;"]

# Multi-stage build for React frontend
FROM node:20-alpine3.21 as build

# Update and upgrade packages for security, then clean up
RUN apk update && \
    apk upgrade && \
    apk add --upgrade libxml2 && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Set working directory
WORKDIR /app

# Copy package files first for better Docker layer caching
COPY package*.json ./

# Install dependencies and clean npm cache
RUN npm install --omit=dev --no-audit --no-fund && \
    npm cache clean --force

# Copy source code
COPY . .

# Build the application with optimizations
RUN GENERATE_SOURCEMAP=false npm run build

# Production stage - use minimal nginx alpine image
FROM nginx:1.25-alpine as production

# Security updates and install only curl for healthcheck, then cleanup
RUN apk update && \
    apk upgrade && \
    apk add --no-cache curl && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

# Remove default nginx content and unnecessary files
RUN rm -rf /usr/share/nginx/html/* && \
    rm -rf /var/log/nginx/* && \
    rm -rf /etc/nginx/conf.d/default.conf

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built application from build stage (only the dist files)
COPY --from=build /app/build /usr/share/nginx/html

# Set proper permissions with minimal footprint and remove source maps
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html && \
    find /usr/share/nginx/html -name "*.map" -delete

# Switch to non-root user for security
USER nginx

# Expose port
EXPOSE 80

# Lightweight health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]