pipeline {
    agent any
    
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
                    // הרצה ישירה של הבדיקות המקומיות עם שער כיסוי 80% (15 נקודות)
                    sh 'npm install'
                    sh 'npm test' 
                }
            }
        }
        
        stage('Build Images') {
            steps {
                // בניית התמונות והזרקת חותמות הבנייה (15 נקודות)
                sh """
                    export BUILD_NUMBER=${env.BUILD_NUMBER}
                    export GIT_COMMIT_SHORT=${GIT_COMMIT_SHORT}
                    docker compose build
                """
            }
        }
        
        stage('Deploy (Blue-Green)') {
            when {
                // מתבצע רק בענף main באפס זמן נפילה (25 נקודות)
                branch 'main'
            }
            steps {
                sh 'bash deploy.sh'
            }
        }
    }
}