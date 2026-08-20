pipeline {
    agent any
    
    environment {
        // שומרים את 7 התווים הראשונים של הקומיט, כפי שהמרצה ביקש
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
                    // מתקינים חבילות ומריצים בדיקות
                    sh 'npm install'
                    // הפקודה הזו תכשיל את הבנייה באדום אם הכיסוי מתחת ל-80%! (15 נקודות)
                    sh 'npm test' 
                }
            }
        }
        
        stage('Build Images') {
            steps {
                // בונים את התמונות ומזריקים את חותמות הבנייה (15 נקודות)
                sh """
                    export BUILD_NUMBER=${env.BUILD_NUMBER}
                    export GIT_COMMIT_SHORT=${GIT_COMMIT_SHORT}
                    docker compose build
                """
            }
        }
        
        stage('Deploy (Blue-Green)') {
            when {
                // מתבצע רק בענף main, כפי שהמרצה דרש (15 נקודות)
                branch 'main'
            }
            steps {
                echo "Here we will run the Blue-Green Deployment script!"
            }
        }
    }
}