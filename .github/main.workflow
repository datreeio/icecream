workflow "ice cream main workflow" {
  on = "push"
  resolves = [
    "Docker Build",
    "Deploy to ECS Fargate",
  ]
}

action "Docker Build" {
  uses = "actions/docker/cli@master"
  args = "build -t icecream . "
}

action "Login to ECR" {
  uses = "actions/aws/cli@aba0951d3bb681880614bbf0daa29b4a0c9d77b8"
  args = "ecr get-login --no-include-email --region $AWS_DEFAULT_REGION | sh"
  secrets = ["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
  env = {
    AWS_DEFAULT_REGION = "us-west-1"
  }
}

action "Docker Tag" {
  uses = "actions/docker/tag@master"
  args = "$IMAGE_NAME $CONTAINER_REGISTRY_PATH/$IMAGE_NAME"
  env = {
    CONTAINER_REGISTRY_PATH = "483104334676.dkr.ecr.us-west-1.amazonaws.com"
    IMAGE_NAME = "icecream"
  }
  needs = ["Docker Build"]
}

action "Push image to ECR" {
  uses = "actions/docker/cli@c08a5fc9e0286844156fefff2c141072048141f6"
  needs = ["Login to ECR", "Docker Tag"]
  args = "push $CONTAINER_REGISTRY_PATH/$IMAGE_NAME"
  env = {
    CONTAINER_REGISTRY_PATH = "483104334676.dkr.ecr.us-west-1.amazonaws.com"
    IMAGE_NAME = "icecream"
  }
}

action "Deploy to ECS Fargate" {
  uses = "silinternational/ecs-deploy@master"
  needs = ["Push image to ECR"]
  args = "--timeout $ECS_TIMEOUT --max-definitions 5 --cluster ${CLUSTER_NAME} --service-name $SERVICE_NAME --image 483104334676.dkr.ecr.us-west-1.amazonaws.com/icecream"
  env = {
    ECS_TIMEOUT = "600"
    CLUSTER_NAME = "demo"
    SERVICE_NAME = "icecream"
    DOCKER_REGISTRY = "483104334676.dkr.ecr.us-west-1.amazonaws.com"
    AWS_DEFAULT_REGION = "us-west-1"
  }
  secrets = ["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
}
