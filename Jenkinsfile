pipeline {
    agent any
    parameters {
        string(name: 'RT_URL', defaultValue: 'yanivnorman.jfrog.io', description: 'Artifactory URL')
        string(name: 'RT_TOKEN', defaultValue: 'eyJ2ZXIiOiIyIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYiLCJraWQiOiI0VG5pYlRVc25DMkxnUURvYkFwS1JJTTdrdC1XNl80ZTd4a1FnbU5adVA4In0.eyJleHQiOiJ7XCJyZXZvY2FibGVcIjpcInRydWVcIn0iLCJzdWIiOiJqZmFjQDAxZnJqZWtmdGozYTRiMTB0d3Fmc3QxeHJ5XC91c2Vyc1wvbWF2ZW4iLCJzY3AiOiJhcHBsaWVkLXBlcm1pc3Npb25zXC9hZG1pbiIsImF1ZCI6IipAKiIsImlzcyI6ImpmZmVAMDAwIiwiZXhwIjoxNjcyOTUzNTA0LCJpYXQiOjE2NDE0MTc1MDQsImp0aSI6ImM3NDJiM2M3LWI3MjgtNDJjYi04NGIyLWU5MWI0MWYzZWRhNCJ9.FKwmFc9RsNyY7yCUCbpKOfy1p2JCJnIc1P8Xak8TTXHBHuJdTg8JyHdoYVbpTO94PgpIuoiIMQorIzbisa2LLfEqGMs18edgSlXpQmVmK_QTRqXUB_n7TaGSOkUXTNb_IkgAEX8aPjL2XMC-XyUApzq0-1mHpgyPs3PQTTbH25cVecOHeiYe8dr-a6A6WNQUDfbzHJoT0kXFuSq1w7oY-ZgDkvQeqFNa9yr85tuQn27ja155bwgT4-eRirivC4-dYorJsqubOUCrgAke_aJNazfiKVZCVXvZjzc_WM2jFVUrYgDK_0c-XlFbt-7xq-RFsT3yX-VRXxdwUcxtapGYZw', description: 'Artifactory Token')
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
                ./jfrog c add artifactory --artifactory-url=\"https://${params.RT_URL}/artifactory\" --url=\"${params.RT_URL}\" --access-token=${params.RT_TOKEN} --interactive=false
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
