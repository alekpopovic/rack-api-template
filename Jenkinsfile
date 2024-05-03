pipeline {
    environment {
        branch = 'main'
        repo = 'git@github.com:alekpopovic/rack-api.git'
        tag = ['git', 'rev-parse', 'HEAD'].execute().text
        registry = 'popac'
        image = 'rack-api'
    }
    agent any
    stages {
        stage('Print variables') {
            steps {
                script {
                    sh "branch $branch"
                    sh "repo $repo"
                    sh "tag $tag"
                    sh "registry $registry"
                    sh "image $image"
                }
            }
        }
        //stage('Cloning our Git') {
        //    steps {
        //        git branch: $branch,
        //            url: $repo
        //    }
        //}
        //stage('Docker build') {
        //    steps {
        //        script {
        //            sh "docker build -t ${$image}:${$tag} ."
        //        }
        //    }
        //}
        //stage('Docker tag') {
        //    steps {
        //        script {
        //            sh "docker tag ${$image}:${$tag} ${$registry}/${$image}:${$tag}"
        //        }
        //    }
        //}
        //stage('Docker rmi') {
        //    steps {
        //        sh "docker rmi ${$image}:${$tag}"
        //        sh "docker rmi ${$registry}/${$image}:${$tag}"
        //    }
        //}
    }
}

