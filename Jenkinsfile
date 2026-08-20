pipeline {
    agent {
        docker {
            image 'node:20-alpine'
            args '-u root'
        }
    }
    
    environment {
        GIT_COMMIT_SHORT = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Test & Coverage Gate') {
            steps {
                dir('api') {
                    sh 'npm install'
                    sh 'npm test' 
                }
            }
        }
        
        stage('Build Images') {
            steps {
                sh """
                    export BUILD_NUMBER=${env.BUILD_NUMBER}
                    export GIT_COMMIT_SHORT=${GIT_COMMIT_SHORT}
                    docker compose build
                """
            }
        }
        
        stage('Deploy (Blue-Green)') {
            when {
                branch 'main'
            }
            steps {
                sh 'bash deploy.sh'
            }
        }
    }
}