/**
 * Main application entry point
 */
const express = require('express');
const config = require('./config');
const routes = require('./routes');
const db = require('./models/db');
const redis = require('./models/redis');
const logger = require('./middleware/logger');
const mermaidflowRoutes = require('./routes/mermaidflow');

// Create Express app
const app = express();
const port = config.server.port;

// Customer ID identification
console.log(`Starting application for customer: ${config.customer.id}`);
console.log(`Environment: ${config.server.env}`);

// Middleware
app.use(express.json());
app.use(logger);

// Register routes
app.use('/', routes);
app.use('/api/mermaidflow', mermaidflowRoutes);

// Start the server
const server = app.listen(port, async () => {
  console.log(`Server running on port ${port}`);
  
  // Test database connection
  await db.testConnection();
  
  // Redis connection is handled in the module initialization
});

// Handle graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
}); 