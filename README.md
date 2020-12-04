# General Information

This repository contains the scripts for deploying a Hyperledger Fabric Network. It has scripts for: 
- creating a ordering service (one ordering node, modus: solo)
- creating a consortium 
- creating a channel
- creating a node
- joining a channel

# Note for Docker for macOS
IMPORTANT: gRPC FUSE-Option MUST be deactivated in Docker Desktop and Docker restarted or Chaincode Installation will NOT work!
(Link to Jira Issue)[https://jira.hyperledger.org/browse/FAB-18134]

# Hyperledger Fabric version 1.x
Please see the fabric-version1x folder 

# Hyperledger Fabric version 2.x
Please see the fabric-version2x folder
