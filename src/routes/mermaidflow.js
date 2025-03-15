/**
 * MermaidFlow API Routes
 */
const express = require('express');
const router = express.Router();
const mermaidFlowClient = require('../utils/mermaidflow');

// Get all MermaidFlow tools
router.get('/tools', async (req, res) => {
  try {
    const tools = await mermaidFlowClient.getTools();
    res.json({
      success: true,
      tools
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Execute a MermaidFlow tool
router.post('/execute', async (req, res) => {
  try {
    const { tool, parameters } = req.body;
    
    if (!tool) {
      return res.status(400).json({
        success: false,
        error: 'Tool name is required'
      });
    }
    
    const result = await mermaidFlowClient.executeTool(tool, parameters || {});
    res.json({
      success: true,
      result
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Check if MermaidFlow service is available
router.get('/status', async (req, res) => {
  try {
    const available = await mermaidFlowClient.isAvailable();
    res.json({
      success: true,
      available,
      message: available ? 'MermaidFlow service is available' : 'MermaidFlow service is not available'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

module.exports = router; 