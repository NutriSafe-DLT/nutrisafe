# General Information

This repository contains the scripts for deploying a Hyperledger Fabric Network. It has scripts for: 
- creating a ordering service (one ordering node, modus: solo)
- creating a consortium 
- creating a channel
- creating a node
- joining a channel


Note that this basic configuration uses pre-generated certificates and
key material, and also has predefined transactions to initialize a 
channel named "mychannel".

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>


# Development
## Environment Linux
We used an UBUNTU 18.04 Server instance.

After setting up the server, the connections and the development environment, we started to install the necessary tools for a running Hyperledger Fabric network (see <a href="https://hyperledger-fabric.readthedocs.io/en/release-1.4/prereqs.html">HL Fabric Docs</a>).
  

## Prerequisites

### Update your system

```
sudo apt-get update
```

### Install

```
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
```


### Installing Docker 
(see <a href="https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-using-the-repository"> Docker Docs</a>).  Make sure the user account has the necessary rights to execute docker. 
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \ $(lsb_release -cs) \ stable"

sudo apt-get install docker-ce docker-ce-cli containerd.io

sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

$ sudo usermod -aG docker <your-user>  
Error message = Got permission denied while trying to connect to the Docker daemon socket at ...
```
### Installing jq

```
sudo apt-get install jq
```

### Installing golang
Follow the instructions on <a href="https://github.com/golang/go/wiki/Ubuntu">golang</a>

```
sudo snap install go --classic
```

Set the environment variables
```
$ export GOROOT=/usr/local/go
$ export GOPATH=/home/ubuntu/Dev/fabric-samples/
$ export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
```

### Download hyperledger/fabric-samples
```
curl -sSL http://bit.ly/2ysbOFE | bash -s
```

### Clone GIT Repository

### NutriSafe Network
1. Generate crytpo materials
2. Start Network
```
./startNetwork.sh
```
3. Stop Network
```
./stopNetwork.sh
```

### Chaincode development
Install gcc compiler
```
apt-get install build-essential
```

### Helpful docker commands
Stop all docker containers
```
docker stop $(docker ps -a -q)
```
Remove all docker containers
```
docker rm $(docker ps -a -q)
```

###

1. Installing Docker
2. Installing Golang --> set Paths 
3. Cloning of the fabric-samples git repo
4. execute https://github.com/hyperledger/fabric/blob/release-1.4/scripts/bootstrap.sh



