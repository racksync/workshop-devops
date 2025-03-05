import adapter from '@sveltejs/adapter-static'; // Changed from adapter-auto to adapter-static
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	// Consult https://svelte.dev/docs/kit/integrations
	// for more information about preprocessors
	preprocess: vitePreprocess(),

	kit: {
			// Using adapter-static for production builds
		adapter: adapter({
			// Output directory for static build
			fallback: 'index.html' // Use index.html as fallback for SPA routing
		})
	}
};

export default config;
