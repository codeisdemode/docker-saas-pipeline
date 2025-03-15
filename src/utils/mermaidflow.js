/**
 * MermaidFlow Integration Module
 * 
 * This module provides a client to interact with the MermaidFlow MCP server.
 */

const axios = require('axios');

class MermaidFlowClient {
  constructor() {
    this.baseUrl = process.env.MERMAIDFLOW_URL || 'http://localhost:5000';
  }

  /**
   * Get available MermaidFlow tools
   * 
   * @returns {Promise<Array>} List of available tools
   */
  async getTools() {
    try {
      const response = await axios.get(`${this.baseUrl}/tools`);
      return response.data.tools || [];
    } catch (error) {
      console.error('Error fetching MermaidFlow tools:', error.message);
      throw new Error(`Failed to fetch MermaidFlow tools: ${error.message}`);
    }
  }

  /**
   * Execute a MermaidFlow tool
   * 
   * @param {string} toolName - Name of the tool to execute
   * @param {Object} params - Parameters for the tool
   * @returns {Promise<any>} Result of the tool execution
   */
  async executeTool(toolName, params) {
    try {
      const response = await axios.post(`${this.baseUrl}/execute`, {
        tool: toolName,
        params: params
      });
      
      if (response.data.status === 'error') {
        throw new Error(response.data.message || 'Unknown error');
      }
      
      return response.data.result;
    } catch (error) {
      console.error(`Error executing MermaidFlow tool ${toolName}:`, error.message);
      throw new Error(`Failed to execute MermaidFlow tool ${toolName}: ${error.message}`);
    }
  }
  
  /**
   * Check if the MermaidFlow service is available
   * 
   * @returns {Promise<boolean>} True if the service is available
   */
  async isAvailable() {
    try {
      await axios.get(`${this.baseUrl}/tools`);
      return true;
    } catch (error) {
      console.error('MermaidFlow service not available:', error.message);
      return false;
    }
  }
}

// Export a singleton instance
const mermaidFlowClient = new MermaidFlowClient();
module.exports = mermaidFlowClient; 