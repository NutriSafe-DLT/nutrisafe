# Deployment preparation
You need to store your username and password for docker hub in the local ansible-vault before you get started.
After storing please replace the values in hosts.yml

To run the playbook use this line:
```
ansible-playbook -i ./hosts.yml -u <<your vm ssh username>> setup-environment.yml --ask-become-pass
```