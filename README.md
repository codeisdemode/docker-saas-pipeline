# Docker SaaS Pipeline

A Docker-based SaaS application with a CI/CD pipeline that deploys customer-specific Docker containers to AWS EC2.

## Overview

This project provides a scalable SaaS architecture where each customer gets their own isolated Docker container running on AWS EC2. The CI/CD pipeline ensures consistent, automated deployments from development to production.

## Key Features

- Multi-tenant architecture with customer isolation
- Automated CI/CD pipeline from dev to production
- Docker-based deployment for consistency
- AWS EC2 infrastructure for hosting customer containers

## CI/CD Pipeline

Our CI/CD pipeline follows industry best practices:

1. **Development Environment**: Developers work with local Docker containers
2. **Continuous Integration**: Automated tests run on GitHub Actions on every commit
3. **Container Registry**: Images are built and pushed to Amazon ECR
4. **Deployment**: Automated deployment to customer-specific EC2 instances
5. **Monitoring**: Integrated monitoring and logging

For detailed information about the CI/CD setup, see the [CI/CD Pipeline Documentation](CI_CD_PIPELINE.md).

## Development Setup

For information on setting up the Docker development environment, please refer to [DOCKER_DEV.md](DOCKER_DEV.md).

## Project Planning

For current project planning and roadmap, see [PLANNING.md](PLANNING.md).

## Getting Started

1. Clone this repository
2. Set up the Docker development environment following [DOCKER_DEV.md](DOCKER_DEV.md)
3. Review [PLANNING.md](PLANNING.md) for current priorities
4. Follow the contribution guidelines in [CONTRIBUTING.md](CONTRIBUTING.md)

## License

[MIT License](LICENSE) 