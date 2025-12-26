pipeline {
    agent any
    
    stages {
        stage('Test') {
            steps {
                echo 'Hello from Jenkins Pipeline!'
                sh 'echo "Current directory: $(pwd)"'
                sh 'ls -la'
            }
        }
    }
}
