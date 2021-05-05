# Deployment preparation

## Install Ansible

Please use the following URL to install Ansible for your platform:
<a href="https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html">Ansible install documentation</a>

## Run playbook(s)
You need to store your username and password for docker hub in the local ansible-vault before you get started.
After storing please replace the values in hosts.yml

To run the playbook use this line:
```
ansible-playbook -i ./hosts.yml -u <<your vm ssh username>> setup-environment.yml --ask-become-pass
```