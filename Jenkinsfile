pipeline {
    agent any

    environment {
        IMAGE_NAME = "jenkins-pipeline-app"
        BUILD_TAG = "${env.BUILD_NUMBER ?: 'local'}"
        COMMIT_SHA = "${env.GIT_COMMIT ?: 'unknown'}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Run Unit Tests') {
            steps {
                // הרצת הבדיקות שהגדרנו ב-package.json
                sh 'npm test'
            }
        }

        stage('Build Docker Image') {
            steps {
                // בניית האימג' של דוקר תוך העברת מספרי הגרסה כ-Build Arguments
                sh "docker build --build-arg BUILD_NUMBER=${env.BUILD_TAG} --build-arg COMMIT_HASH=${env.COMMIT_SHA} -t ${env.IMAGE_NAME}:${env.BUILD_TAG} ."
            }
        }

        stage('Deploy / Run') {
            steps {
                // עצירה וניקוי של קונטיינר ישן אם קיים, והרמת החדש
                sh "docker stop app-container || true"
                sh "docker rm app-container || true"
                sh "docker run -d --name app-container -p 8000:8000 ${env.IMAGE_NAME}:${env.BUILD_TAG}"
            }
        }
    }

    post {
        success {
            echo "Pipeline executed successfully and app deployed!"
        }
        failure {
            echo "Pipeline failed during one of the stages."
        }
    }
}