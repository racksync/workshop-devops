import { defineConfig } from 'vitest/config';
import { svelte } from '@sveltejs/vite-plugin-svelte';

export default defineConfig({
  plugins: [svelte({ hot: !process.env.VITEST })],
  test: {
    environment: 'jsdom',
    include: ['tests/**/*.{test,spec}.{js,ts}'],
    globals: true,
    setupFiles: ['./tests/setup.js']
  }
});
