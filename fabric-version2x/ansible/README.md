# Ansible setup
## macOS

### 1. Install ansible node on your machine
Installing with only user privileges (no admin required):
`python -m pip install --user ansible`

### 2. Setup ssh-agent to avoid having to enter certificate passwords
Ansible assumes that you are using certificates to authenticate to other ssh targets. As these are usually password-protected, you need to add them to ssh-agent:
`ssh-agent`
`ssh-add`
The last command automatically adds .ssh/id_rsa to the agent and asks for your key password. In order to add more keys just type them after ssh-add e.g.:
`ssh-add mycert.pem`

### 3. Install docker_container dependency
`ansible-galaxy collection install community.docker`
`pip install docker-py`