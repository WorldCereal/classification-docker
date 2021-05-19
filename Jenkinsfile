#!/usr/bin/env groovy

// This Jenkinsfile uses the internal VITO shared library

@Library('lib')_

containerImageBuildPipeline {
  dockerfile           = 'Dockerfile'
  docker_registry_prod = 'vito-docker.artifactory.vgt.vito.be'
  image_name           = 'worldcereal'
  run_tests            = false
}
