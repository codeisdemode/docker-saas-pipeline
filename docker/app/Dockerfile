# Base Node.js image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Set environment variables
ARG NODE_ENV=development
ENV NODE_ENV=$NODE_ENV

# Install dependencies first (for better caching)
COPY package*.json ./
RUN npm install

# Copy source code
COPY . .

# Expose port
EXPOSE 3000

# Command to run
CMD ["npm", "run", "dev"] 