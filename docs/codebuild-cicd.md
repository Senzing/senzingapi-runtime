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
1. [Configure test pipeline](#configure-test-pipeline)
1. [Configure deploy pipeline](#configure-deploy-pipeline)
1. [Deploy new pipeline](#deploy-new-pipeline)
1. [Design considerations](#design-considerations)

## Pre-requisites
1. Senzing AWS account
1. Senzing github account

## Design considerations

When designing this pipeline, a couple of factors were considered. First, I liked the simplicity and convenience of github actions. It was easy to setup, and it provided me with the convenience of notification built in. When a github action fails, it would block the pull request and send a notifiction via email to the developer by default. Additionally, it was easy to setup, simply put a yaml file in the .github/workflows folder and you are good to go. This allows developers to take charge and customize their own pipeline.

I also like the access to a vast ecosystem that codebuild offers. One shortfall for github is that it is rather limited in the environment that it provides. Whereas in codebuild, it has access to the full suite of products that are available in AWS e.g. lambda, cloudformation, ecs. This grants a developer the power to create more sophisticated test cases, e.g. recreating an environment and testing if the code change breaks anything within that environment.

With what is mentioned above, this ci/cd pipeline uses both github actions and codebuild, so that we are able to marry the benefits from each product.

## Configure test pipeline

To configure the test pipeline, lets first start from the source of the trigger, the github 

## Configure deploy pipeline
## Deploy new pipeline





