# Codebuild CI/CD Pipeline

The goal of the codebuild ci/cd pipeline is to relieve developers of menial devops tasks (e.g. build, test and deploy docker images). 

## Overview

The pipeline seeks to automate 2 task
- test code change to smoke out any breaking changes
- deploy code that is pushed to the main branch to the specified container registry 

The following is a flow diagram of each task is automated with github action and codebuild.

![flow diagram](/assets/codebuild-cicd-architecture-diagram.png)






