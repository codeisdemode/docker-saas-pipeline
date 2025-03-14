# Development Workflow

This document outlines the workflow for developing inside Docker containers and integrating with GitHub.

## Docker Development Best Practices

### 1. Always Develop Inside Docker

Developing inside Docker containers ensures that all developers work in the same environment, preventing "it works on my machine" problems. Key benefits:

- Consistent development environment across all team members
- Matches production environment closely
- Dependencies are isolated and containerized
- No need to install development tools locally (except Docker)

### 2. Container Structure

Our development setup includes multiple containers:

- **App Container**: Node.js application
- **Database Container**: PostgreSQL for data storage
- **Redis Container**: For caching and session management
- **Nginx Container**: For routing and serving static assets

### 3. Volume Mounting

We use Docker volumes to enable live code reloading:

- Source code is mounted from the host to the container
- Node modules are stored in a named volume for performance
- Database data is persisted in a volume

## Development Workflow

### 1. Local Development

1. Start the Docker development environment:
   ```bash
   docker-compose -f docker-compose.dev.yml up -d
   ```

2. View logs in real-time:
   ```bash
   docker-compose -f docker-compose.dev.yml logs -f app
   ```

3. Make changes to code on your local machine - they will be reflected in the container automatically thanks to volume mounting and nodemon.

4. Test your changes in the browser or API client at `http://localhost`.

5. Run tests inside the container:
   ```bash
   docker-compose -f docker-compose.dev.yml exec app npm test
   ```

### 2. GitHub Integration

1. Commit your changes locally:
   ```bash
   git add .
   git commit -m "Description of changes"
   ```

2. Push to GitHub (using a feature branch for new features):
   ```bash
   git checkout -b feature/my-new-feature
   git push origin feature/my-new-feature
   ```

3. Create a Pull Request on GitHub.

4. CI/CD pipeline will:
   - Run tests
   - Build the Docker image
   - Push to Amazon ECR if tests pass
   - Deploy to development environment

5. After review and approval, merge to main branch.

6. CI/CD pipeline will automatically deploy to production environment.

## Branching Strategy

We follow the GitHub Flow branching strategy:

1. `main` branch is always deployable and represents the production environment.
2. For new features, create a feature branch from `main`: `feature/feature-name`.
3. For bug fixes, create a bug branch from `main`: `bugfix/bug-name`.
4. Create a Pull Request to merge changes back to `main`.
5. CI runs tests and builds on all Pull Requests.
6. After review and approval, merge to `main`.

## Database Migrations

For database changes:

1. Create migrations in the `migrations` directory.
2. Test migrations locally using the Docker development environment.
3. Migrations run automatically during deployment.

## Best Practices

1. **Container optimization**: Keep containers small and focused.
2. **Environment variables**: Use `.env` files for local development, but use secrets management in production.
3. **Logging**: Use structured logging and centralize logs.
4. **Security**: Regularly update dependencies and scan for vulnerabilities.
5. **Testing**: Write automated tests for all code.
6. **Documentation**: Document architecture decisions and API endpoints.
7. **Code quality**: Use linters and formatters to maintain code quality.

## Troubleshooting

1. **Container issues**: 
   ```bash
   docker-compose -f docker-compose.dev.yml down
   docker-compose -f docker-compose.dev.yml up -d
   ```

2. **Database reset**:
   ```bash
   docker-compose -f docker-compose.dev.yml down -v
   docker-compose -f docker-compose.dev.yml up -d
   ```

3. **View container logs**:
   ```bash
   docker-compose -f docker-compose.dev.yml logs -f [service_name]
   ```

4. **Access container shell**:
   ```bash
   docker-compose -f docker-compose.dev.yml exec [service_name] sh
   ``` 