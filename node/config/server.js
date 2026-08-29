'use strict';

const http = require('http');
const os = require('os');

const PORT = process.env.NODE_PORT || 3000;
const HOST = process.env.NODE_HOST || '0.0.0.0';
const NODE_ENV = process.env.NODE_ENV || 'production';

const server = http.createServer((req, res) => {
  const startTime = Date.now();

  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('healthy');
    return;
  }

  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    message: 'Hello from Node.js',
    uptime: process.uptime(),
    hostname: os.hostname(),
    environment: NODE_ENV,
    timestamp: new Date().toISOString()
  }));
});

server.listen(PORT, HOST, () => {
  console.log(`Node.js server running on ${HOST}:${PORT} [${NODE_ENV}]`);
});

server.on('error', (err) => {
  console.error('Server error:', err);
  process.exit(1);
});

process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully');
  server.close(() => {
    process.exit(0);
  });
});

module.exports = server;