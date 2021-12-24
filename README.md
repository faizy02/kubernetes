# kubernetes

Helpful easy to use add-user script that can be used by K8s admins to generate the required certiifcate and create config files. 

It will create username directory and all related files regarding that user will be inside the directly. Later, K8s admin need to share the {username}.config,.key,.crt file with the new user
Usage : 
./addUser.sh <username>
