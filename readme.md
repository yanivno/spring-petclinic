# Spring PetClinic Sample Application with Dockerfile and Jenkinsfile

## Configurations validated with

 ubuntu 18.04.02 
 - Openjdk 8 JRE - 8u312 x64
 - docker CE runtime - 20.10.12
 - Jenkins WAR 2.319.1
 
 macos BigSur 11.6.2
 - OpenJDK 8 JRE - 8u311 x64
 - docker CE runtime 20.10.11
 - Jenkins 2.319.1

#Prerequisites to compile run the pipeline in Jenkins

### docker installation
(Ubuntu) installation instructions are in https://docs.docker.com/engine/install/ubuntu/
validate with docker ps && docker --version

### java openjdk-8-jre installation
(Ubuntu) apt install openjdk-8-jre -y

### Jenkins installation
(Ubuntu) Installation file download through https://www.jenkins.io/download/

### Install Docker & Docker pipeline plugins in Jenkins
After configuring Jenkins, using the default plugins, we need to install Docker & Docker pipeline plugin
Manage Jenkins > Manage Plugins > slide to "Available" and locate Docker, Docker pipeline and installed them.
a reboot to jenkins might be required

### Giving permissions to jenkins account to run docker containers on node
on ubuntu we need to give permissions to jenkins service account to connect to docker.sock
with a slight variation of https://docs.docker.com/engine/install/linux-postinstall/
```
sudo groupadd docker
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

## Configure pipeline on Jenkins

### configure credentials for Docker repo on Artifactory
Manage Jenkins > Manage Credentials (under Security) > Select Jenkins (default store) > select "Global Credentials (unrestricted) > Add Credentials (side menu):
  - Kind : Username and Password
  - Scope : Global
  - ID: rt-yanivnorman-jfrog-io-docker
  - Username: yaniv.no@gmail.com
  - Password: Aa123456!

### create a new pipeline
New Item
  - Name: sprint-petclinic-ynorman
  - Type: Pipeline

Go to Pipeline section and configure:
  - Defnition: Pipeline script from SCM
  - SCM: Git
  - Repository URL : https://github.com/yanivno/spring-petclinic.git
  - Branches to build - Branch Specifier : */main
  - Script Path : Jenkinsfile
  
Save and Build Now to run the pipeline in Jenkins

## Running the application
pre-compiled image (publicly available):

docker run -p 5000:8080 yanivnorman.jfrog.io/default-docker-local/petclinic:57

browse to http://localhost:5000
