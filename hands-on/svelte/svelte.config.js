import adapter from '@sveltejs/adapter-node';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	kit: {
		// Use adapter-node for SSR
		adapter: adapter({
			 // Use default output directory (will be .svelte-kit)
			// No need to specify 'out' as it defaults to .svelte-kit
		}),
		// No need to prerender in SSR mode
		prerender: {
			default: false
		}
	}
};

export default config;
