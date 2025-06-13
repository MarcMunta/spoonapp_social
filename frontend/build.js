import { build, context } from 'esbuild';
import { argv } from 'node:process';

const watch = argv.includes('--watch');
const options = {
  entryPoints: ['frontend/src/main.js'],
  bundle: true,
  format: 'esm',
  outfile: 'static/main.js',
  sourcemap: watch,
  minify: !watch,
};

(async () => {
  if (watch) {
    const ctx = await context(options);
    await ctx.watch();
    console.log('Watching for changes...');
  } else {
    await build(options);
    console.log('Build completed.');
  }
})();
