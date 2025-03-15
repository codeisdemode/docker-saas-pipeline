/**
 * Application configuration
 */
require('dotenv').config();

module.exports = {
  // Server settings
  server: {
    port: process.env.PORT || 3000,
    env: process.env.NODE_ENV || 'development',
  },
  
  // Customer settings
  customer: {
    id: process.env.CUSTOMER_ID || 'development',
    name: `Customer ${process.env.CUSTOMER_ID || 'development'}`,
  },
  
  // Database settings
  database: {
    url: process.env.DATABASE_URL || 'postgres://postgres:postgres@db:5432/app_dev',
  },
  
  // Redis settings
  redis: {
    url: process.env.REDIS_URL || 'redis://redis:6379',
  },
}; 