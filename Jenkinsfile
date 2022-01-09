pipeline {
    agent any
    environment {
        RT_CREDS = credentials('rt-yanivnorman-jfrog-io-docker')
    }
    parameters {
        string(name: 'RT_URL', defaultValue: 'yanivnorman.jfrog.io', description: 'Artifactory URL')
        string(name: 'RT_MAVEN_REPO_NAME', defaultValue: 'default-maven-local', description: 'Maven repo name to use')
        string(name: 'RT_DOCKER_REPO_NAME', defaultValue: 'default-docker-local', description: 'Docker repo name to use')
    }
    stages { 
        stage("Clone"){
            steps{
                git branch: 'main', credentialsId: 'github-yanivno-jenkins-token', url: 'https://github.com/yanivno/spring-petclinic'
                stash name:'scm', includes:'*'
            }
        }
        stage("Build and Test") {
            agent{
                docker {
                    image "maven:3.8.4-jdk-11"
                    args "-v ${workspace}:/app -w /app"
                    reuseNode true
                }
            }
            steps{
                sh "mvn -Dcheckstyle.skip -DskipTests -B -X -e clean package"
                sh "mvn -Dcheckstyle.skip -X -e test"
            }
        }
        stage("Setup jfrog cli") {
            steps {
                withCredentials([usernamePassword(credentialsId: 'rt-yanivnorman-jfrog-io-docker', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh """
                    curl -fL https://getcli.jfrog.io | bash -s v2
                    chmod +x jfrog
                    ./jfrog c remove artifactory --quiet=true
                    ./jfrog c add artifactory --artifactory-url=\"https://${params.RT_URL}/artifactory\" --url=\"${params.RT_URL}\" --user=\"$USERNAME\" --password=\"$PASSWORD\" --interactive=false --basic-auth-only=true
                    ./jfrog rt ping
                    """
                }
            }
        }
        stage("upload artifact") {
            steps {
                sh "./jfrog rt u target/*.jar ${params.RT_MAVEN_REPO_NAME}"
            }
        }
        stage("Build Docker Image") {
            steps {
                withCredentials([usernamePassword(credentialsId: 'rt-yanivnorman-jfrog-io-docker', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh "cp target/*.jar petclinic.jar"
                    sh "docker build . -t petclinic:${BUILD_NUMBER}"
                    
                    echo "------------------------------------------------------------------------"
                    echo "BUILT DOCKER IMAGE petclinic:${BUILD_NUMBER}"
                    echo "------------------------------------------------------------------------"

                    sh "docker login ${params.RT_URL} -u $USERNAME -p $PASSWORD"
                    sh "docker tag petclinic:${BUILD_NUMBER} ${params.RT_URL}/${params.RT_DOCKER_REPO_NAME}/petclinic:${BUILD_NUMBER}"
                    sh "docker push ${params.RT_URL}/${params.RT_DOCKER_REPO_NAME}/petclinic:${BUILD_NUMBER}"
                    
                    echo "------------------------------------------------------------------------"
                    echo "PUSHED DOCKER IMAGE : ${params.RT_URL}/${params.RT_DOCKER_REPO_NAME}/petclinic:${BUILD_NUMBER}"
                    echo "------------------------------------------------------------------------"
                }
            }
        }
    }
}
