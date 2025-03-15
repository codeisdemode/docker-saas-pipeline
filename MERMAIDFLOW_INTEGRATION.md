# MermaidFlow Integration

This document explains how MermaidFlow has been integrated into our Docker SaaS Pipeline project to provide AI-powered workflow automation capabilities.

## Overview

MermaidFlow is an AI-powered workflow automation framework that provides task orchestration, tool integration, and language model interaction. By integrating it with our SaaS Pipeline, we enable AI automation capabilities for each customer in an isolated, secure manner.

## Architecture

The integration follows our multi-tenant architecture principles:

1. **Container Isolation**: Each customer gets their own isolated MermaidFlow container
2. **API Gateway**: Nginx routes traffic to the appropriate MermaidFlow instance
3. **Client Integration**: Node.js application interacts with MermaidFlow through a dedicated client
4. **Database Isolation**: Each MermaidFlow instance gets its own database schema

## Services

The integration adds the following components:

- **MermaidFlow Container**: Python-based application with MCP server
- **API Routes**: Endpoints in our Node.js application to interact with MermaidFlow
- **Client Library**: Utility functions to communicate with the MermaidFlow service
- **Database Schema**: Dedicated schema for MermaidFlow persistence

## API Endpoints

The following endpoints are available for interacting with MermaidFlow:

- `GET /api/mermaidflow/tools`: List available MermaidFlow tools
- `POST /api/mermaidflow/execute`: Execute a MermaidFlow tool
- `GET /api/mermaidflow/status`: Check if MermaidFlow service is available

Direct access to the MermaidFlow MCP server is also available at:
- `/mermaidflow/tools`: List available tools (proxied to the MCP server)
- `/mermaidflow/execute`: Execute a tool (proxied to the MCP server)

## Configuration

The following environment variables are used to configure the MermaidFlow integration:

- `MERMAIDFLOW_URL`: URL of the MermaidFlow service (default: http://mermaidflow:5000)
- `OPENAI_API_KEY`: OpenAI API key for language model interactions
- `OPENWEATHER_API_KEY`: OpenWeather API key for weather data (optional)
- `TAVILY_API_KEY`: Tavily API key for search functionality (optional)

## Usage Example

```javascript
// Using the MermaidFlow client in Node.js
const mermaidFlowClient = require('./utils/mermaidflow');

// Get available tools
const tools = await mermaidFlowClient.getTools();
console.log('Available tools:', tools);

// Execute a tool
const result = await mermaidFlowClient.executeTool('add', { a: 5, b: 3 });
console.log('Result:', result); // 8
```

## Database Initialization

The MermaidFlow integration automatically initializes its database schema during container startup. The database initialization script creates:

1. A dedicated `mermaidflow` database
2. A `mermaidflow` user with appropriate permissions
3. A `mermaidflow` schema for data isolation

## Deployment

In production, each customer will have their own:

1. MermaidFlow container with customer-specific configuration
2. Database schema for persistence
3. API keys and credentials

## Monitoring

The MermaidFlow integration includes:

1. Health checks for the MermaidFlow service
2. Logging of tool executions and errors
3. Status endpoint for monitoring service availability 