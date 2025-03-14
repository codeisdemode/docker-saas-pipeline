# Docker Development Environment

This document outlines the Docker-based development environment for our SaaS application.

## Prerequisites

- Docker Desktop installed (version 4.0+)
- Docker Compose installed (version 2.0+)
- Git
- AWS CLI configured (for deployment)

## Local Development Environment

Our local development environment uses Docker Compose to run all necessary services:

```bash
# Start the development environment
docker-compose -f docker-compose.dev.yml up -d

# View logs
docker-compose -f docker-compose.dev.yml logs -f

# Stop the development environment
docker-compose -f docker-compose.dev.yml down
```

## Project Structure

```
.
├── docker/                 # Docker configuration files
│   ├── app/                # Application Dockerfile
│   ├── nginx/              # Nginx configuration for routing
│   └── scripts/            # Helper scripts
├── docker-compose.dev.yml  # Development docker-compose configuration
├── docker-compose.prod.yml # Production docker-compose configuration
└── src/                    # Application source code
```

## Docker Image Management

### Building Images

```bash
# Build the application image
docker build -t saas-app:dev -f docker/app/Dockerfile .

# Build with specific arguments
docker build \
  --build-arg NODE_ENV=development \
  -t saas-app:dev \
  -f docker/app/Dockerfile .
```

### Testing Images Locally

```bash
# Run a container from the built image
docker run -p 3000:3000 saas-app:dev

# Run with environment variables
docker run -p 3000:3000 -e "DB_HOST=localhost" saas-app:dev
```

## Multi-tenant Architecture

Each customer gets their own isolated Docker container. This is achieved by:

1. Building a base Docker image with the application
2. Creating customer-specific configuration during deployment
3. Running dedicated containers with customer configuration
4. Using Nginx for routing traffic to the correct container

## Container Networking

The containers use the following network architecture:

- Development: Docker Compose network for local services
- Production: AWS VPC network with security groups

## Volumes and Persistence

Data persistence is managed through Docker volumes:

```yaml
volumes:
  - ./data:/app/data
  - customer-data:/app/customer-data
```

## CI/CD Integration

Our Docker images are integrated with the CI/CD pipeline:

1. Images are built automatically in GitHub Actions
2. Tagged with build number and git commit hash
3. Pushed to Amazon ECR
4. Deployed to customer-specific EC2 instances

For more details on the CI/CD pipeline, see [CI_CD_PIPELINE.md](CI_CD_PIPELINE.md).

## Troubleshooting

Common Docker-related issues and their solutions:

1. **Container not starting**: Check logs with `docker logs [container_id]`
2. **Port conflicts**: Ensure the ports specified in docker-compose.yml are available
3. **Permission issues**: Check volume mount permissions
4. **Image build failures**: Review the Dockerfile and ensure all dependencies are available 