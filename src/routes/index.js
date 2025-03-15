/**
 * Main routes definition
 */
const express = require('express');
const router = express.Router();
const config = require('../config');

// Health check endpoint
router.get('/health', (req, res) => {
  res.status(200).send('ok');
});

// API root
router.get('/', (req, res) => {
  res.json({
    message: 'Docker SaaS Pipeline API',
    customer: config.customer.id,
    environment: config.server.env
  });
});

// Customer-specific endpoint
router.get('/api/customer', (req, res) => {
  res.json({
    id: config.customer.id,
    name: config.customer.name,
    created: new Date().toISOString()
  });
});

module.exports = router; 