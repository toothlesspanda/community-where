// esbuild.config.js
//"build": "esbuild app/javascript/application.js --bundle --sourcemap --format=esm --outdir=app/assets/builds --public-path=/assets",
// esbuild.config.js
const esbuild = require('esbuild');
const { sassPlugin } = require('esbuild-sass-plugin');
const copyStaticFiles = require('esbuild-copy-static-files');

const buildOptions = {
    entryPoints: [
        'app/javascript/application.js',
        // 'app/assets/stylesheets/application.scss' // Add this
    ],
    bundle: true,
    outdir: 'app/assets/builds',
    publicPath: '/assets',
    assetNames: 'images/[name]-[hash]',
    loader: {
        '.png': 'file',
        '.svg': 'file',
        '.woff': 'file',
        '.woff2': 'file',
        '.ttf': 'file',
    },
    plugins: [
        sassPlugin({
            loadPaths: ['./node_modules'],
        }),
        copyStaticFiles({
            src: './node_modules/leaflet/dist/images',
            dest: './app/assets/builds/images',
            watch: true
        })
    ],
    target: 'es2017',
    format: 'esm',
    sourcemap: true,
};

(async () => {
    const ctx = await esbuild.context(buildOptions);

    if (process.argv.includes('--watch')) {
        await ctx.watch();
        console.log('👀 Watching for changes...');
    } else {
        await ctx.rebuild();
        await ctx.dispose();
        console.log('✅ Build complete');
    }
})();