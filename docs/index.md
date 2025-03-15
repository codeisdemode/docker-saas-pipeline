# SaaS Pipeline Documentation

## Overview

This documentation covers the architecture and components of the SaaS Pipeline system with a focus on MermaidFlow integration and user-specific AI assistants.

## Contents

- [MVP Architecture](mvp-architecture.md) - The simplified implementation for our user-specific AI assistant framework with a single vertical agent
- [Enterprise Architecture](enterprise-architecture.md) - The ultimate production architecture for an enterprise-grade deployment
- [Business Model](business-model.md) - Our hybrid business model and go-to-market strategy

## Purpose

These documents serve as reference points for our development process:

1. The MVP Architecture document outlines our immediate implementation goals for a functioning prototype
2. The Enterprise Architecture document details our long-term vision to ensure our current decisions align with future requirements
3. The Business Model document explains our phased approach to market entry and revenue generation

## Getting Started

To run the documentation server locally:

```bash
# Start the documentation service
docker-compose -f docker-compose.dev.yml up docs

# Access the documentation
# Open http://localhost:8080 in your browser
```

Documentation is also available inside the containers at:
- `/app/docs/` in the app container
- `/app/docs/` in the mermaidflow container 