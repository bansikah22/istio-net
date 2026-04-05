# ---- Dependencies Stage ----
# This stage installs production dependencies
FROM node:18-alpine AS dependencies
WORKDIR /app
COPY package*.json ./
RUN npm install --production

# ---- Release Stage ----
# This is the final, optimized image
FROM node:18-alpine AS release
WORKDIR /app
ENV NODE_ENV=production

# Create and use a non-root user for security
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 appuser
USER appuser

# Copy dependencies and application code
COPY --from=dependencies /app/node_modules ./node_modules
COPY . .

# Expose the application port
EXPOSE 3001

# Define the build argument and the command to run the app
ARG APP_VERSION=index.v2.js
CMD node ${APP_VERSION}
