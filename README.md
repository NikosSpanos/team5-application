# team5 DevOps infrastructure

# Login to terraform cloud
1. Ask for an invitation to the cloud terraform organization from project admin: nikos spanos
2. Once invited, open terminal on a laptop/desktop with terraform installed
3. Git clone the current git repo of the infrastructure.
4. Once in the local folder of the repo go to either the *production_environment* or *development_environment* folder.
5. In the infrastructure folder, using your terminal cli, run the command **terraform init**
   - If the command is successful go to step 6.
   - If the command is not successful, you will prompt to connect to terraform cloud using the terminal command **terraform login**. With terraform login you will be asked to  grant access to your laptop/desktop for it to log on the terraform cloud and generate a new API token. Select yes if necessary. Open the terraform cloud account and copy the generated token on clipboard. Then past the generated Token on your terminal cli (*keep in mind that you won't be able to see the pasted token, so just press enter to proceed*). Hopefully, you will successfully get access on terraform cloud. Now proceed to step 6.
6. Now that you are connected on terraform cloud you have access to the terraform states of both the development and production infrastructures. Try to connection to the virtual machines by running **vm_connestion.sh** script.
