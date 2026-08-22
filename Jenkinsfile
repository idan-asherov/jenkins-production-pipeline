pipeline {
    agent any
    
    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }
        
        stage('Test & Coverage Gate') {
            steps {
                dir('api') {
                    sh "npm install"
                    sh "npm test"
                }
            }
        }
        
        stage('Build Images') {
            steps {
                sh '''
                export BUILD_NUMBER=${BUILD_NUMBER}
                export GIT_COMMIT_SHORT=$(git rev-parse --short HEAD)
                docker-compose build
                '''
            }
        }
        
        stage('Deploy (Blue-Green)') {
            when {
                anyOf {
                    branch 'main'
                    expression { env.GIT_BRANCH == 'origin/main' || env.GIT_BRANCH == 'main' }
                }
            }
            steps {
                sh "bash deploy.sh"
            }
        }
    }
    
    post {
        success {
            echo "✅ Pipeline finished successfully!"
        }
        failure {
            echo "❌ Pipeline failed! Check logs."
        }
    }
}
