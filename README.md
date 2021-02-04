# General Information

This repository contains the scripts for deploying a Hyperledger Fabric Network. It has scripts for: 
- creating a ordering service (one ordering node, modus: solo)
- creating a consortium 
- creating a channel
- creating a node
- joining a channel
- generating demo data and initializing the nutrisafe data model

# Note for Docker for macOS
IMPORTANT: gRPC FUSE-Option MUST be deactivated in Docker Desktop and Docker restarted or Chaincode Installation will NOT work!
(Link to Jira Issue)[https://jira.hyperledger.org/browse/FAB-18134]
It is possible that the Chaincode deployment will not work on macOS due to the above issue (it only works when gRPC FUSE is activated).

# Hyperledger Fabric version 1.x
Please see the fabric-version1x folder 

# Hyperledger Fabric version 2.x
Please see the fabric-version2x folder

# Demodata Script
In the demodata folder you will find a small python script which you can use to initialize the data model or generate data for a network.
You can run the script from the commandline using `python generate_demodata.py`
