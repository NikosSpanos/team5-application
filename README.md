# team5 DevOps infrastructure

## Login to terraform cloud
1. Ask for an invitation to the cloud terraform organization from project admin: nikos spanos
2. Once invited, open terminal on a laptop/desktop with terraform installed
3. Git clone the current git repo of the infrastructure.
4. Once in the local folder of the repo go to either the *production_environment* or *development_environment* folder.
5. In the infrastructure folder, using your terminal cli, run the command **terraform init**
   - If the command is successful go to step 6.
   - If the command is not successful, you will prompt to connect to terraform cloud using the terminal command **terraform login**. With terraform login you will be asked to  grant access to your laptop/desktop for it to log on the terraform cloud and generate a new API token. Select yes if necessary. Open the terraform cloud account and copy the generated token on clipboard. Then past the generated Token on your terminal cli (*keep in mind that you won't be able to see the pasted token, so just press enter to proceed*). Hopefully, you will successfully get access on terraform cloud. Now proceed to step 6.
6. Now that you are connected on terraform cloud you have access to the terraform states of both the development and production infrastructures. Try to connection to the virtual machines by running **vm_connestion.sh** script.

### Install docker: https://phoenixnap.com/kb/how-to-install-docker-on-ubuntu-18-04

### Install Jenkins
*https://www.digitalocean.com/community/tutorials/how-to-install-jenkins-on-ubuntu-18-04* (optional link)
*https://www.jenkins.io/doc/book/installing/linux/* (officail link from Jenkins)
Execute the bash script: *install_start_jenkins.sh* (execute this script if your don't want to follow the instructions) --*IMPORTANT: this script should be executed on the vm instance*

### Start Jenkins
Possible errors that Jenkins might not start:<br>
   a. Port 8080 is not exposed. To solve this issue go to the infrastructure and check that a security rule (https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) is created for this port. <br>
   b. Your tfstate does not include the public ip address as an output. It's important to save the public ip of the virtual machine on tfstate because the scripts access it. <br>
   c. You need to install *jq* to execute the script. <br>
   d. You dont have installed firefox command. The specific command is pre-installed with Ubuntu 18.04LTS distribution.

Once jenkins opens on firefox you will be prompted to paste the *initialAdminPassword*. To retrieve it run the command (on the vm's erminal with jenkins installed): **cat /var/lib/jenkins/secrets/initialAdminPassword**

### Re-installing vm
Keep in  mind that if for any reason changes are made to any of the vm instances you can update the respective resource by deleting the following resources from azure client portal:
   - OS disk resource. Important because it's attached to the vm instance. If the developer forgets to delete the os-disk instance terrform apply with exit with error.
   - VM instance that needs the update.
