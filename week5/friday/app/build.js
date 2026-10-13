const fs = require('fs');
fs.rmSync('dist', { recursive: true, force: true });
fs.mkdirSync('dist', { recursive: true });
fs.copyFileSync('src/index.js', 'dist/index.js');
console.log('Build complete: dist/index.js');
