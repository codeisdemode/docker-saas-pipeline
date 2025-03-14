const express = require('express');
require('dotenv').config();

// Create Express app
const app = express();
const port = process.env.PORT || 3000;

// Customer ID from environment variables
const customerId = process.env.CUSTOMER_ID || 'development';

// Middleware
app.use(express.json());

// Routes
app.get('/', (req, res) => {
  res.json({
    message: 'Docker SaaS Pipeline API',
    customer: customerId,
    environment: process.env.NODE_ENV
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).send('ok');
});

// Customer-specific endpoint
app.get('/api/customer', (req, res) => {
  res.json({
    id: customerId,
    name: `Customer ${customerId}`,
    created: new Date().toISOString()
  });
});

// Start the server
app.listen(port, () => {
  console.log(`Server running for customer ${customerId} on port ${port}`);
  console.log(`Environment: ${process.env.NODE_ENV}`);
}); 