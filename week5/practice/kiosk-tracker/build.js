const fs = require('fs');
const path = require('path');

// Build step: copy the app (API code and screens) into dist/.
// dist/ is the folder that gets packaged and published to Nexus.
const dist = path.join(__dirname, 'dist');

fs.rmSync(dist, { recursive: true, force: true });
fs.mkdirSync(dist);
fs.cpSync(path.join(__dirname, 'src'), path.join(dist, 'src'), { recursive: true });
fs.cpSync(path.join(__dirname, 'public'), path.join(dist, 'public'), { recursive: true });

console.log('Build complete: dist/');
