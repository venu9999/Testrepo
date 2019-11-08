pipeline {
    agent any
    stages {
        stage('git checkout') {
            steps {
            
             git 'https://github.com/venu9999/Testrepo.git'
                
            }
        }
        stage('Running shellscript') {
            steps {
               sh '''
                  chmod +x dev-db.sh
                  ./dev-db.sh
                  '''
            }
        }
    }
}