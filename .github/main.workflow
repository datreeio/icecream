workflow "ice cream main workflow" {
  on = "push"
  resolves = [
    "GitHub Action for Docker",
    "Push image to ECR",
  ]
}

action "GitHub Action for Docker" {
  uses = "actions/docker/cli@master"
  args = "build -t icecream ."
  env = {
    AWS_DEFAULT_REGION = "us-west-1"
  }
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
  uses = "actions/docker/tag@c08a5fc9e0286844156fefff2c141072048141f6"
  needs = ["GitHub Action for Docker"]
  args = "[\"$IMAGE_NAME\",\"$CONTAINER_REGISTRY_PATH/$IMAGE_NAME\"]"
  env = {
    CONTAINER_REGISTRY_PATH = "483104334676.dkr.ecr.us-west-1.amazonaws.com"
    IMAGE_NAME = "icecream"
  }
}

action "Push image to ECR" {
  uses = "actions/docker/cli@c08a5fc9e0286844156fefff2c141072048141f6"
  needs = ["Login to ECR", "Docker Tag"]
  args = "[\"push\",\"$CONTAINER_REGISTRY_PATH/$IMAGE_NAME\"]"
  env = {
    CONTAINER_REGISTRY_PATH = "483104334676.dkr.ecr.us-west-1.amazonaws.com"
    IMAGE_NAME = "icecream"
  }
}
