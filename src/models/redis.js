/**
 * Redis connection module
 */
const redis = require('redis');
const config = require('../config');

// Create Redis client
const redisClient = redis.createClient({
  url: config.redis.url
});

// Connect to Redis
const connectRedis = async () => {
  try {
    await redisClient.connect();
    console.log('Redis connection successful');
    return true;
  } catch (err) {
    console.error('Redis connection error:', err);
    return false;
  }
};

// Initialize Redis connection with error handling
(async () => {
  try {
    await connectRedis();
  } catch (err) {
    console.log('Redis initialization error, will retry on demand');
  }
})();

// Redis client wrapper with basic operations
module.exports = {
  client: redisClient,
  connect: connectRedis,
  set: async (key, value, ttl) => {
    try {
      const result = ttl 
        ? await redisClient.set(key, value, { EX: ttl })
        : await redisClient.set(key, value);
      return result;
    } catch (err) {
      console.error('Redis set error:', err);
      return null;
    }
  },
  get: async (key) => {
    try {
      return await redisClient.get(key);
    } catch (err) {
      console.error('Redis get error:', err);
      return null;
    }
  }
}; 