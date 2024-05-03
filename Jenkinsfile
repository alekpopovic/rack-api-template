pipeline {
    //environment {
    //    registry = 'popac/rack-api'
    //    registryCredential = 'dockerhub'
    //    dockerImage = ''
    //}
    agent any
    stages {
        stage('Cloning our Git') {
            steps {
                git branch: 'main',
                    url: 'git@github.com:alekpopovic/rack-api.git'
            }
        }
        stage('Docker image') {
            steps {
                script {
                    sh "docker build -t rails-api:${commitSha()} ."
                }
            }
        }
        stage('Docker tag') {
            steps {
                script {
                    sh "docker tag rack-api:${commitSha()} popac/rack-api:${commitSha()}"
                }
            }
        }
        stage('Docker rmi') {
            steps {
                sh "docker rmi rack-api:${commitSha()}"
                sh "docker rmi popac/rack-api:${commitSha()}"
            }
        }
    }
}

String commitSha() {
    return sh(returnStdout: true, script: 'git rev-parse HEAD')
}
