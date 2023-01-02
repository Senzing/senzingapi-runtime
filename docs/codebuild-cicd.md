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
1. [Deploy new pipeline](#deploy-new-pipeline)


## Pre-requisites
1. Senzing AWS account
1. Senzing github account

## Design considerations

When designing this pipeline, a couple of factors were considered. First, I liked the simplicity and convenience of github actions. It was easy to setup, and it provided me with the convenience of notification built in. When a github action fails, it would block the pull request and send a notifiction via email to the developer by default. Additionally, it was easy to setup, simply put a yaml file in the .github/workflows folder and you are good to go. This allows developers to take charge and customize their own pipeline.

I also like the access to a vast ecosystem that codebuild offers. One shortfall for github is that it is rather limited in the environment that it provides. Whereas in codebuild, it has access to the full suite of products that are available in AWS e.g. lambda, cloudformation, ecs. This grants a developer the power to create more sophisticated test cases, e.g. recreating an environment and testing if the code change breaks anything within that environment.

With what is mentioned above, this ci/cd pipeline uses both github actions and codebuild, so that we are able to marry the benefits from each product.

## Configure test pipeline

To configure the test pipeline, lets first start with the github action file located at [senzing-cicd-buildtest.yaml](/.github/workflows/senzing-cicd-buildtest.yaml). This file provides github with the steps to take when a pull request is made to the main branch. The file has 2 steps.

**Step 1: Configure AWS Credentials**

This configures the github action environment to be authenticated to the Senzing AWS environment. The credentials are stored in the github action secrets, which can only be modified if an administrator account is used.

**Step 2: Run Codebuild**

This step does 2 things. It runs the codebuild project with the name senzing-cicd-buildtest and it overrides the codebuild buildspec file with [test.yml](/cicd-test/test.yml). This means that the codebuild project runs with the test.yml instead of what is written on the codebuild project. This is necessary as this provides the developer to craft their own buildspec file and run it using the codebuild project.

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
## Deploy new pipeline





