import { defineConfig } from 'vite';
import elm from 'vite-plugin-elm';

export default defineConfig({
  plugins: [elm()],
  build: {
    rollupOptions: {
      output: {
        entryFileNames: 'assets/[name].js',
        chunkFileNames: 'assets/[name].js',
        assetFileNames: 'assets/[name].[ext]'
      }
    }
  }
});
