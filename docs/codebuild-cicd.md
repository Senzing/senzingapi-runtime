# Codebuild CI/CD Pipeline

The goal of the Codebuild CI/CD pipeline is to provide a scaffold for Senzing developers to easily automate pesky devops tasks such as testing and deployment.

## Overview

Currently, the pipeline seeks to automate 2 task
1. Test any changes in the source code to smoke out breaking changes before it is integrated into the main branch.
1. Build code that is merged into the main branch and deploy to it's respective container registry

The following is a flow diagram of the automation done with github action and codebuild.

![flow diagram](/assets/codebuild-cicd-architecture-diagram.png)

## Contents
1. [Pre-requisites](#pre-requisites)
1. [Design considerations](#design-considerations)
1. [Configure test pipeline](#configure-test-pipeline)
1. [Configure deploy pipeline](#configure-deploy-pipeline)


## Pre-requisites
1. Senzing AWS account
1. Senzing github account

## Design considerations

The following are some design considerations when building this pipeline.

1. Simplicity
   
The setup for this pipeline should be simple and intuitive for a developer to use. Similar to github actions, the developer would just need to make modifications to buildspec file to customize their own test/deploy pipeline.
   
2. Convenience
   
The pipeline should come with certain features out of the box. E.g. when a test fails, it should immediately block the pull request and notify the developer via email.

3. Access to resource

The pipeline should have access to a vast number of resources. One major shortfall for github action is that it is rather limited in its environment, whereas codebuild has access to a full suite of products that are available in AWS (e.g. lambda, cloudformation).

To achieve the design considerations above, the pipeline a mix of both github actions and codebuild, so that it is able to reap the benefits from each product.

## Configure test pipeline

To configure the test pipeline, lets first start with the github action file located at [senzing-cicd-buildtest.yaml](/.github/workflows/senzing-cicd-buildtest.yaml). This file provides github with the steps to take when a pull request is made to the main branch. The file has 2 steps.

**Step 1: Configure AWS Credentials**

This configures the github action environment to be authenticated to the Senzing AWS environment. The credentials are stored in the github action secrets, which can only be modified if an administrator account is used.

**Step 2: Run Codebuild**

This step does 2 things. It runs the codebuild project with the name senzing-cicd-buildtest and it overrides the codebuild buildspec file with [test.yml](/cicd-test/test.yml). This means that the codebuild project runs with the test.yml instead of what is written on the codebuild project. This is necessary as this provides the developer the capability to craft their own buildspec file and run it using the codebuild project.

Currently, test.yml logins to dockerhub (increasing it's docker pull limit) and builds the docker image. The docker image is then ran with [test_script.sh](/cicd-test/test_script.sh), which does some basic tests to make sure that the image is working fine

```
version: 0.2

env:
  variables:
    DOCKER_IMAGE_TAG: "senzingapi-runtime:latest"
  secrets-manager:
    DOCKERHUB_PASS: "/dockerhub/credentials:password"
    DOCKERHUB_USER: "/dockerhub/credentials:username"

phases:
  install:
    commands:
      - echo Entered the install phase...
      - apt-get update -y
  pre_build:
    commands:
      - echo Entered the pre_build phase...
      - docker login --username $DOCKERHUB_USER --password $DOCKERHUB_PASS
    finally:
      - echo This always runs even if the login command fails 
  build:
    commands:
      - echo Entered the build phase...
      - echo Build started on `date`
      - docker build -t $DOCKER_IMAGE_TAG .
      - echo Build completed on `date`
  post_build:
    commands:
      - echo Entered the post_build phase...
      - echo Running test
      - docker run $DOCKER_IMAGE_TAG ./test_script.sh
```

Any changes that a developer wants to make to the unit/integration test can be done by making changes to test.yml. E.g. if a developer would like to add in a unit testing component, all it would take, would be to add in an extra command line in the post_build stage.

## Configure deploy pipeline

To configure the deploy pipeline, lets first start with the github action file located at [senzing-cicd-deploy.yaml](/.github/workflows/senzing-cicd-deploy.yaml). This file provides github with the steps to take when a push is made to the main branch, which typically only happens during a merge into the main branch. The file has 2 steps.

**Step 1: Configure AWS Credentials**

This configures the github action environment to be authenticated to the Senzing AWS environment. The credentials are stored in the github action secrets, which can only be modified if an administrator account is used.

**Step 2: Run Codebuild**

This step does 2 things. It runs the codebuild project with the name senzing-cicd-deploy and it overrides the codebuild buildspec file with [deploy.yml](/cicd-deploy/deploy.yml). This means that the codebuild project runs with the deploy.yml instead of what is written on the codebuild project. This is necessary as this provides the developer the capability to craft their own buildspec file and run it using the codebuild project.

As the code that has reached this stage can be assumed to have been tested, no further testing is done in deploy.yml. Instead, the buildspec logins to both ECR and dockerhub. The buildspec then builds the image and pushes it to ECR.

```
version: 0.2

env:
  variables:
    IMAGE_REPO_NAME: "senzingapi-runtime"
    IMAGE_TAG: "latest"
    ECR_URI: "283428323412.dkr.ecr.us-east-1.amazonaws.com"
  secrets-manager:
    DOCKERHUB_PASS: "/dockerhub/credentials:password"
    DOCKERHUB_USER: "/dockerhub/credentials:username"

phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $ECR_URI
      - docker login --username $DOCKERHUB_USER --password $DOCKERHUB_PASS
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...          
      - docker build -t $IMAGE_REPO_NAME:$IMAGE_TAG .
      - docker tag $IMAGE_REPO_NAME:$IMAGE_TAG $ECR_URI/$IMAGE_REPO_NAME:$IMAGE_TAG      
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker image...
      - docker push $ECR_URI/$IMAGE_REPO_NAME:$IMAGE_TAG
```



