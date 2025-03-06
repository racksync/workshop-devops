# SvelteKit SSR Application

This is a SvelteKit application configured to run in Server-Side Rendering (SSR) mode in a Docker container.

## Development

To run the application in development mode:

```bash
cd svelte
yarn dev
```

## Docker Deployment

To build and run the Docker container:

```bash
docker build -t svelte-ssr-app .
docker run -p 3000:3000 svelte-ssr-app
```

Or using docker-compose:

```bash
docker-compose up -d
```

## Configuration

The application is configured to:

1. Build the SvelteKit application in SSR mode
2. Run the server on port 3000
3. Handle errors gracefully with a fallback mechanism

## Structure

- The build process generates output in `.svelte-kit/output/`
- The Docker image runs the SSR server directly from the built application

## Troubleshooting

If you encounter any issues:

1. Check the Docker container logs: `docker logs <container-id>`
2. Verify that the build process completed successfully
3. Ensure port 3000 is available on your host machine
