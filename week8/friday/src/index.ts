import http from 'http';
import { readFileSync } from 'fs';
import path from 'path';

// The version comes from APP_VERSION, which the Docker image sets to the exact
// image tag (for example 1.0.0-a1b2c3d). If it is not set, fall back to the
// version in package.json.
const pkg = JSON.parse(readFileSync(path.join(__dirname, '..', 'package.json'), 'utf8'));
const version: string = process.env.APP_VERSION ?? pkg.version;
const port = Number(process.env.PORT ?? 3001);

const server = http.createServer((req, res) => {
  // The health endpoint: answers with a small JSON message.
  if (req.method === 'GET' && req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ status: 'ok', service: 'kk-payments', version }));
    return;
  }
  // Anything else is not found.
  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ error: 'not found' }));
});

server.listen(port, () => {
  console.log(`kk-payments ${version} listening on port ${port}`);
});

// Docker and Kubernetes send SIGTERM to ask a container to stop. Close the
// server cleanly instead of being cut off.
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down');
  server.close(() => process.exit(0));
});
