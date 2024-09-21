**************************Pre-requisites to perform Ansible actions private-ec2s from local system**************************
We have to set passwordless login to private-ec2s:
    1. Create a key-pair on local (pass file name as "key"): ssh-keygen -t rsa -b 4096 -C "EMAIL"
    2. Move the key and key.pub created to ssh folder: mv key ~/.ssh/ , mv key.pub ~/.ssh/
    3. Login to bastion and then to private ec2 via pem file like previous:
        a. ssh -i "PATH_TO_FILE/FILENAME.pem" ubuntu@<bastion-public-ip>
        b. ssh -i "FILENAME.pem" ubuntu@<private-ec2-private-ip>
    4. Copy contents of public-key from local: cat ~/.ssh/key.pub
    5. Edit the authorized_keys file and append the public-key : vi ~/.ssh/authorized_keys
    6. Perform same step-5 for all private-ec2 instances and exit.
    7. Edit the local ssh config to set Forward-proxy: vi ~/.ssh/config
        Host bastion
        HostName  <bastion-public-ip>
        User ubuntu
        IdentityFile ~/.ssh/devops-key-pair.pem
        ForwardAgent yes

        Host private-ec2-0
        HostName <private-ec2-0-private-ip>
        User ubuntu
        ProxyJump bastion
        IdentityFile ~/.ssh/key

        Host private-ec2-1
        HostName <private-ec2-1-private-ip>
        User ubuntu
        ProxyJump bastion
        IdentityFile ~/.ssh/key
    8. Start the SSH Agent: eval $(ssh-agent), ssh-add ~/.ssh/key
    9. Test the connection: ssh bastion, ssh private-ec2-0, ssh private-ec2-1

In any case of error, give necessary file permission like below:
chmod 600 ~/.ssh/key

MAKE SURE TO UPDATE THE SSH CONFIG WITH BASTION'S PUBLIC IP ONCE INSTANCE IS RESTARTED: vi ~/.ssh/config
********************************************************************************************************

****************************************************Implemetation****************************************************
1. Create an inventory file to define hosts. (In this inventory file we want to achieve same pre-requisite but this time via ansible)
Define hosts:
    [bastion]
    bastion ansible_host=<bastion-public-ip> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/devops-key-pair.pem
    [master]
    private-ec2-0 ansible_host=<private-ec2-0-private-ip> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/key
    [worker]
    private-ec2-1 ansible_host=<private-ec2-1-private-ip> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/key
Add the hosts to a group:
    [private_ec2s:children]
    master
    worker
Set forward-proxy for private-ec2s:
    [private_ec2s:vars]
    ansible_ssh_common_args='-o ProxyJump=bastion'

2. Creating playbooks to install required dependencies. Comments added to each task.

**************************Kubernetes dependency download issue (not required to address - fixed in playbooks directly)***************************
If we run the commonly used task to download Kubernetes apt repository, we will find the following configuration everywhere:
- name: Add Kubernetes APT repository
      apt_repository:
        repo: deb http://apt.kubernetes.io/ kubernetes-xenial main
        state: present

This will result in error:
fatal: [private-ec2-0]: FAILED! =>
{"changed": false, "msg": "Failed to update apt cache: W:Updating from such a repository can't be done securely, and is therefore disabled by default.,
W:See apt-secure(8) manpage for repository creation and user configuration details.,
W:https://download.docker.com/linux/ubuntu/dists/focal/InRelease: Key is stored in legacy trusted.gpg keyring (/etc/apt/trusted.gpg), see the DEPRECATION section in apt-key(8) for details.,
E:The repository 'http://apt.kubernetes.io kubernetes-xenial Release' does not have a Release file."}

The issue is that kubernetes does not support apt Package Repositories and it is now reffered as Kubernetes Legacy Package Repositories which was frozen in September 2023.
So, with higher version of OS like we are using Ubuntu-24. This configuration will not work.
Reference link:
https://kubernetes.io/blog/2023/08/31/legacy-package-repository-deprecation/

Because of this we have to update our Ansible configuration and use the steps given by Kubernetes to migrate to Kubernetes Community Owned Packages.
Refer: https://kubernetes.io/blog/2023/08/15/pkgs-k8s-io-introduction/#how-to-migrate

In the above link 3 steps are given:
1. Update the repository path: echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
2. Update the public-key signing: curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
3. For version older than Ubuntu-22, create the key folder manually: /etc/apt/keyrings

We have to incorporate same via tasks in ansible:
1. We create the required folder for key:
    - name: Create directory for APT keyrings
      ansible.builtin.file:
        path: /etc/apt/keyrings
        state: directory
        mode: '0755'
2. With the given step-2 above we download the key:
    - name: Download and convert Kubernetes APT GPG key
      ansible.builtin.shell: |
        curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key |
        gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
      args:
        creates: /etc/apt/keyrings/kubernetes-apt-keyring.gpg
3. Add Kubernetes repository with the step-1:
    - name: Add Kubernetes Repository
      ansible.builtin.apt_repository:
        repo: "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /"
        filename: kubernetes
        state: present
      become: yes

This will download the Kubernetes repository as required.
********************************************************************************************************