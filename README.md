# aws-terraform-module
Terraform module to deploy Pi into ecs

Resources created in this module:
- an ECS cluster with four services - panintelligence dashboard. scheduler, renderer and pirana
- EFS backed storage, configured using Lambda, for dashboard persistent data such as themes and keys

This module is created to enable a minimal deployment into your existing AWS infrastructure, assuming networking is already in place. 
A full example of how this module can be used, with supporting resoources configured, can be seen in the examples folder. 
This provides a fully functional configuration out of the box (aside from a registered domain)