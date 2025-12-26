pipeline {
    agent any
    
    environment {
        REGISTRY = 'localhost:30500'
        IMAGE_NAME = 'argocd-demo'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '📥 Checking out source code...'
                checkout scm
            }
        }
        
        stage('Generate Version') {
            steps {
                script {
                    env.BUILD_VERSION = sh(
                        script: "date +%Y%m%d%H%M%S",
                        returnStdout: true
                    ).trim() + "-${BUILD_NUMBER}"
                    echo "📌 Build version: ${env.BUILD_VERSION}"
                }
            }
        }
        
        stage('Build Maven') {
            steps {
                echo '🔨 Building with Maven...'
                sh '''
                    docker run --rm -v "$(pwd)":/app -w /app maven:3.9-eclipse-temurin-17 mvn clean package -DskipTests
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                sh """
                    docker build -t ${IMAGE_NAME}:${BUILD_VERSION} .
                    docker tag ${IMAGE_NAME}:${BUILD_VERSION} ${IMAGE_NAME}:latest
                """
            }
        }
        
        stage('Push to Registry') {
            steps {
                echo '⬆️ Pushing to local registry...'
                sh """
                    docker tag ${IMAGE_NAME}:${BUILD_VERSION} ${REGISTRY}/${IMAGE_NAME}:${BUILD_VERSION}
                    docker tag ${IMAGE_NAME}:latest ${REGISTRY}/${IMAGE_NAME}:latest
                    docker push ${REGISTRY}/${IMAGE_NAME}:${BUILD_VERSION}
                    docker push ${REGISTRY}/${IMAGE_NAME}:latest
                """
            }
        }
        
        stage('Update Helm Values') {
            steps {
                echo '📝 Updating Helm values.yaml...'
                sh """
                    sed -i 's|tag: ".*"|tag: "${BUILD_VERSION}"|g' helm/argocd-demo/values.yaml
                    sed -i 's|repository: .*|repository: ${REGISTRY}/${IMAGE_NAME}|g' helm/argocd-demo/values.yaml
                    
                    echo "Updated values.yaml:"
                    cat helm/argocd-demo/values.yaml | head -15
                """
            }
        }
        
        stage('Commit and Push') {
            steps {
                echo '📤 Committing and pushing to GitHub...'
                withCredentials([usernamePassword(credentialsId: 'github-credentials', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                    sh """
                        git config user.name "Jenkins CI"
                        git config user.email "jenkins@local"
                        git add helm/argocd-demo/values.yaml
                        git diff --staged --quiet || git commit -m "🚀 [Jenkins] Update image to ${BUILD_VERSION}"
                        git push https://\${GIT_USERNAME}:\${GIT_PASSWORD}@github.com/haivutuan93/argocd-demo.git HEAD:main
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo """
✅ ========================================
✅ BUILD SUCCESSFUL!
✅ ========================================
📦 Image: ${REGISTRY}/${IMAGE_NAME}:${env.BUILD_VERSION}
🔄 ArgoCD will auto-sync in ~3 minutes
🌐 App URL: http://localhost:30080
✅ ========================================
            """
        }
        failure {
            echo '❌ Build failed!'
        }
    }
}
