const http = require('http');

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/html');
  res.end(`
    <html>
      <head>
        <title>Kubernetes Sample App</title>
        <style>
          body { font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }
          h1 { color: #0069ff; }
          .container { border: 1px solid #ddd; padding: 20px; border-radius: 5px; }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>Hello from Kubernetes!</h1>
          <p>This application is running on DigitalOcean Kubernetes.</p>
          <p>Server time: ${new Date().toISOString()}</p>
          <p>Hostname: ${process.env.HOSTNAME || 'unknown'}</p>
        </div>
      </body>
    </html>
  `);
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
