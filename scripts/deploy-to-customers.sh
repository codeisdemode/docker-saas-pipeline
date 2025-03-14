#!/bin/bash
# Script to deploy Docker containers to customer-specific EC2 instances

set -e

# Configuration
AWS_REGION=${AWS_REGION:-"us-west-2"}
ECR_REPOSITORY=${ECR_REPOSITORY:-"saas-app"}
IMAGE_TAG=${GITHUB_SHA:-"latest"}

# Get the ECR repository URL
ECR_REPOSITORY_URL=$(aws ecr describe-repositories --repository-names ${ECR_REPOSITORY} --region ${AWS_REGION} | jq -r '.repositories[0].repositoryUri')

# Get list of active customers
echo "Getting list of active customers..."
CUSTOMER_IDS=$(aws ec2 describe-instances \
  --filters "Name=tag:Managed,Values=terraform" "Name=instance-state-name,Values=running" \
  --query "Reservations[*].Instances[*].Tags[?Key=='Customer'].Value" \
  --output text \
  --region ${AWS_REGION})

# Check if we found any customers
if [ -z "$CUSTOMER_IDS" ]; then
  echo "No active customers found. Exiting."
  exit 0
fi

# For each customer, deploy the application
for CUSTOMER_ID in $CUSTOMER_IDS; do
  echo "Deploying to customer: $CUSTOMER_ID"
  
  # Get the EC2 instance ID for this customer
  INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Customer,Values=${CUSTOMER_ID}" "Name=instance-state-name,Values=running" \
    --query "Reservations[*].Instances[*].InstanceId" \
    --output text \
    --region ${AWS_REGION})
  
  if [ -z "$INSTANCE_ID" ]; then
    echo "No running instance found for customer $CUSTOMER_ID. Skipping."
    continue
  fi
  
  echo "Found instance $INSTANCE_ID for customer $CUSTOMER_ID"
  
  # Get database and Redis connection details from Parameter Store
  DATABASE_URL=$(aws ssm get-parameter \
    --name "/saas/${CUSTOMER_ID}/database-url" \
    --with-decryption \
    --query "Parameter.Value" \
    --output text \
    --region ${AWS_REGION})
  
  REDIS_URL=$(aws ssm get-parameter \
    --name "/saas/${CUSTOMER_ID}/redis-url" \
    --with-decryption \
    --query "Parameter.Value" \
    --output text \
    --region ${AWS_REGION})
  
  # Create deployment command
  DEPLOYMENT_COMMAND=$(cat <<EOF
#!/bin/bash
set -e

# Pull the latest image
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPOSITORY_URL}
docker pull ${ECR_REPOSITORY_URL}:${IMAGE_TAG}

# Stop and remove existing container
docker stop customer-${CUSTOMER_ID} || true
docker rm customer-${CUSTOMER_ID} || true

# Run the new container
docker run -d --name customer-${CUSTOMER_ID} \
  -p 80:80 \
  -e NODE_ENV=production \
  -e DATABASE_URL="${DATABASE_URL}" \
  -e REDIS_URL="${REDIS_URL}" \
  -e CUSTOMER_ID="${CUSTOMER_ID}" \
  -v /data/${CUSTOMER_ID}:/app/data \
  --restart always \
  ${ECR_REPOSITORY_URL}:${IMAGE_TAG}

# Run health check
for i in {1..30}; do
  if curl -s http://localhost/health | grep -q "ok"; then
    echo "Health check passed!"
    exit 0
  fi
  echo "Waiting for container to be healthy... (\$i/30)"
  sleep 2
done

echo "Health check failed after 30 attempts. Rolling back..."
docker stop customer-${CUSTOMER_ID}
docker rm customer-${CUSTOMER_ID}
exit 1
EOF
)
  
  # Execute the deployment command on the instance
  echo "Deploying to instance $INSTANCE_ID..."
  
  # Send the command to the instance using SSM Run Command
  COMMAND_ID=$(aws ssm send-command \
    --instance-ids "$INSTANCE_ID" \
    --document-name "AWS-RunShellScript" \
    --comment "Deploy Docker container for customer $CUSTOMER_ID" \
    --parameters commands="$DEPLOYMENT_COMMAND" \
    --output-s3-bucket-name "saas-app-deployments" \
    --output-s3-key-prefix "deployments/$CUSTOMER_ID" \
    --region ${AWS_REGION} \
    --query "Command.CommandId" \
    --output text)
  
  echo "Deployment command sent. Command ID: $COMMAND_ID"
  
  # Wait for the command to complete
  echo "Waiting for deployment to complete..."
  aws ssm wait command-executed \
    --command-id "$COMMAND_ID" \
    --instance-id "$INSTANCE_ID" \
    --region ${AWS_REGION}
  
  # Check the command status
  STATUS=$(aws ssm list-command-invocations \
    --command-id "$COMMAND_ID" \
    --instance-id "$INSTANCE_ID" \
    --details \
    --query "CommandInvocations[0].Status" \
    --output text \
    --region ${AWS_REGION})
  
  if [ "$STATUS" = "Success" ]; then
    echo "Deployment to customer $CUSTOMER_ID successful!"
  else
    echo "Deployment to customer $CUSTOMER_ID failed. Status: $STATUS"
    
    # Get the command output for debugging
    aws ssm get-command-invocation \
      --command-id "$COMMAND_ID" \
      --instance-id "$INSTANCE_ID" \
      --region ${AWS_REGION}
    
    # We continue with other customers rather than failing the entire script
    # This allows us to deploy to as many customers as possible
  fi
  
  echo "-----------------------------------------"
done

echo "Deployment process completed!" 