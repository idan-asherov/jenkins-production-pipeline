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
        
        stage('Integration Test') {
            steps {
                sh '''
                echo "=== Starting isolated environment for Integration Test ==="
                export COMPOSE_PROJECT_NAME=integration-test
                
                # הרמת הסביבה הזמנית (Web + API)
                docker-compose up -d

                echo "Waiting for services to boot (10 seconds)..."
                sleep 10

                echo "Testing communication from Web to API..."
                # אנחנו משתמשים בקונטיינר זמני של curl על אותה הרשת כדי לדגום את שירות ה-web (פורט 8000)
                TEST_RESULT=$(docker run --rm --network bg-network curlimages/curl -s http://integration-test-web-1:8000 || echo "failed")
                echo "Raw Web Response: $TEST_RESULT"

                echo "Tearing down Integration Test environment..."
                # כיבוי וניקוי סביבת הטסטים מיד לאחר מכן
                docker-compose -p integration-test down

                # וידוא ששירות ה-web אכן החזיר מידע שמקורו ב-API (המילה "greets")
                if echo "$TEST_RESULT" | grep -q "greets"; then
                    echo "✅ Integration Test Passed: Web successfully fetched data from API!"
                else
                    echo "❌ Integration Test Failed: Web could not communicate with API!"
                    exit 1
                fi
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