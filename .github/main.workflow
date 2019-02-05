workflow "ice cream main workflow" {
  on = "push"
  resolves = [
    "NPM Build",
    "Docker Build",
    "Deploy to ECS Fargate",
    "Deploy only on master",
  ]
}

action "NPM Build" {
  uses = "actions/npm@master"
  args = "install"
}

action "NPM Test" {
  uses = "actions/npm@3c8332795d5443adc712d30fa147db61fd520b5a"
  needs = ["NPM Build"]
  args = "test"
}

action "Docker Build" {
  uses = "actions/docker/cli@master"
  needs = ["NPM Test"]
  args = "build -t icecream . "
}

action "Login to ECR" {
  uses = "actions/aws/cli@aba0951d3bb681880614bbf0daa29b4a0c9d77b8"
  needs = ["NPM Test"]
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

action "Deploy only on master" {
  uses = "actions/bin/filter@a9036ccda9df39c6ca7e1057bc4ef93709adca5f"
  needs = ["Push image to ECR"]
  args = "branch master"
}

action "Deploy to ECS Fargate" {
  uses = "silinternational/ecs-deploy@master"
  needs = ["Deploy only on master"]
  args = "--timeout 600 --max-definitions 5 --cluster demo --service-name icecream --image 483104334676.dkr.ecr.us-west-1.amazonaws.com/icecream"
  env = {
    CLUSTER_NAME = "demo"
    SERVICE_NAME = "icecream"
    DOCKER_REGISTRY = "483104334676.dkr.ecr.us-west-1.amazonaws.com"
    AWS_DEFAULT_REGION = "us-west-1"
  }
  secrets = ["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY"]
}

