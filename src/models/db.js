/**
 * Database connection module
 */
const { Pool } = require('pg');
const config = require('../config');

// Create a new database pool connection
const pool = new Pool({
  connectionString: config.database.url,
});

// Database connection test
const testConnection = async () => {
  try {
    const client = await pool.connect();
    console.log('Database connection successful');
    client.release();
    return true;
  } catch (err) {
    console.error('Database connection error:', err);
    return false;
  }
};

module.exports = {
  pool,
  query: (text, params) => pool.query(text, params),
  testConnection,
}; 