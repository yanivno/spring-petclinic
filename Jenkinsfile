pipeline {
    agent any
    environment {
        RT_TOKEN = credentials('rt-yanivnorman-jfrog-io')
    }
    parameters {
        string(name: 'RT_URL', defaultValue: 'yanivnorman.jfrog.io', description: 'Artifactory URL')
        string(name: 'RT_MAVEN_REPO_NAME', defaultValue: 'default-maven-local', description: 'Maven repo name to upload artifact')
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
                    image "maven:3.8.4-jdk-8"
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
                sh """
                curl -fL https://getcli.jfrog.io | bash -s v2
                chmod +x jfrog
                ./jfrog c remove artifactory --quiet=true
                ./jfrog c add artifactory --artifactory-url=\"https://${params.RT_URL}/artifactory\" --url=\"${params.RT_URL}\" --access-token=${RT_TOKEN_PSW} --interactive=false
                ./jfrog rt ping
                """
            }
        }
        stage("upload artifact") {
            steps {
                sh "./jfrog rt u target/*.jar ${params.RT_MAVEN_REPO_NAME}"
            }
        }
        stage("Build Docker Image") {
            steps {
                sh "cp target/*.jar petclinic.jar"
                sh "docker build . -t petclinic:${BUILD_NUMBER}"
                echo "------------------------------------------------------------------------"
                echo "BUILT DOCKER IMAGE petclinic:${BUILD_NUMBER}"
                echo "------------------------------------------------------------------------"
            }
        }
    }
}
