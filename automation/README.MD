# Deployment preparation

## Install Ansible

Please use the following URL to install Ansible for your platform:
<a href="https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html">Ansible install documentation</a>

## Set up SSH Agent on your host machine

Start by instantiation of the ssh agent on your machine using this command, afterwards run ssh-add (you can skip the arguments if you just generated a standard SSH key).

This solution uses SSH Agent Forwarding - this means that ansible will use your own SSH Certificates and these have to be configured in github as accepted keys, otherwise this will not work. On the other hand this is the most secure way because we do not include any private keys with the playbook itself.

```
eval `ssh-agent -s`
ssh-add -K ~/.ssh/id_rsa
```
## Run playbook(s)
You need to store your username and password for docker hub in the local ansible-vault before you get started.

After storing please replace the values in hosts.yml with your deployment hosts. This playbook was developed with a Linux Virtual Machine running on the local machine which ansible ssh-es into.

To run the playbook to setup your environment use this line:
```
ansible-playbook -i ./hosts.yml -u <<your vm ssh username>> setup-environment.yml --ask-become-pass
```

After the playbook has run you will have a folder in your designated vm user: /home/user/nutrisafe-test where you have the network and the chaincode. Here you can go ahead and manually run the startNetwork or installCC scripts. 