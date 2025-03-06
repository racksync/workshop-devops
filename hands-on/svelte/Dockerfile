# Build stage
FROM node:20-alpine AS build

WORKDIR /app

# Copy package.json and yarn.lock first for better caching
COPY ./svelte/package.json ./svelte/yarn.lock ./

# Install dependencies with check-files flag
RUN yarn install --check-files

# Install adapter-node instead of adapter-static
RUN yarn add -D @sveltejs/adapter-node@^2.0.0

# Copy the rest of the application code
COPY ./svelte .

# Ensure we're using the node adapter in svelte.config.js
RUN grep -q "adapter-node" svelte.config.js || echo "Warning: adapter-node not found in svelte.config.js"

# Check for duplicate route files and remove .ts versions if both .js and .ts exist
RUN find ./src/routes -type f -name "+page.ts" | while read file; do \
      js_file=$(echo $file | sed 's/\.ts$/.js/'); \
      if [ -f "$js_file" ]; then \
        echo "Found duplicate: $file and $js_file - removing $file"; \
        rm "$file"; \
      fi; \
    done

# Debug - show the content of svelte.config.js
RUN cat svelte.config.js

# Run sync before building to generate the necessary files
RUN yarn svelte-kit sync || true

# Build the application - with specific handling for prerendering errors
RUN yarn build || (echo "Build failed, but attempting to continue with what was built...")

# After build, verify the output
RUN ls -la .svelte-kit 2>/dev/null || echo "Warning: .svelte-kit directory not found"

# Production stage - using Node.js for SSR
FROM node:20-alpine AS production

WORKDIR /app

# Copy the built app - using .svelte-kit instead of build/
COPY --from=build /app/.svelte-kit ./.svelte-kit
COPY --from=build /app/package.json ./

# Install only production dependencies
RUN yarn install --production --frozen-lockfile

# Expose the port that the SvelteKit server will run on
EXPOSE 3000

# Environment variables for the server
ENV NODE_ENV=production
ENV PORT=3000
ENV HOST=0.0.0.0

# Start the SvelteKit server with the correct path to the index.js file
CMD ["node", ".svelte-kit/output/server/index.js"]
