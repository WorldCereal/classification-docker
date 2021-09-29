#!/usr/bin/env groovy

// This Jenkinsfile uses the internal VITO shared library

@Library('lib')_

containerImageBuildPipeline {
  credentials_id       = 'worldcereal_docker_registry'
  dockerfile           = 'Dockerfile'
  docker_registry_prod = 'hfjcmwgl.gra5.container-registry.ovh.net/world-cereal'
  image_name           = 'classification'
  run_tests            = false
}
