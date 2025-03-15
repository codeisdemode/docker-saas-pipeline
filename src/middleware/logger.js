/**
 * Request logger middleware
 */
const config = require('../config');

const requestLogger = (req, res, next) => {
  const start = Date.now();
  const { method, originalUrl, ip } = req;
  
  // Process the request
  next();
  
  // After request is processed, log the details
  res.on('finish', () => {
    const duration = Date.now() - start;
    const { statusCode } = res;
    
    console.log(
      `[${new Date().toISOString()}] ${method} ${originalUrl} ${statusCode} ${duration}ms - ${ip} - Customer: ${config.customer.id}`
    );
  });
};

module.exports = requestLogger; 