pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "ap-south-1"
        CLUSTER_NAME       = "staging-demo"
        SONAR_PROJECT_KEY  = "k8s-devops-project"
        DOCKER_IMAGE       = "k8s-demo-app"
        TF_DIR             = "tf_code"

        // Feature toggles (SAFE DEFAULTS)
        ENABLE_EKS         = "false"
        ENABLE_DOCKER      = "false"
        ENABLE_SONAR       = "false"
    }

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    stages {

        stage('Checkout Source Code') {
            steps {
                checkout scm
            }
        }

        stage('Verify Tooling') {
            steps {
                sh '''
                  terraform --version
                  docker --version || true
                  kubectl version --client || true
                  aws --version
                  trivy --version || true
                  sonar-scanner --version || true
                  aws sts get-caller-identity
                '''
            }
        }

        stage('Terraform Validate (CI SAFE – NO BACKEND)') {
            steps {
                dir("${TF_DIR}") {
                    sh '''
                      echo "==> Cleaning Terraform backend & cache"
                      rm -rf .terraform .terraform.lock.hcl backend.tf

                      terraform init -backend=false -reconfigure
                      terraform validate
                    '''
                }
            }
        }

        stage('Configure kubeconfig (EKS)') {
            when {
                expression { env.ENABLE_EKS == "true" }
            }
            steps {
                sh '''
                  aws eks update-kubeconfig \
                    --region ${AWS_DEFAULT_REGION} \
                    --name ${CLUSTER_NAME}

                  kubectl get nodes
                '''
            }
        }

        stage('SonarQube Code Scan') {
            when {
                expression { env.ENABLE_SONAR == "true" }
            }
            environment {
                SONAR_TOKEN = credentials('sonarqube-token')
            }
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                      sonar-scanner \
                        -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                        -Dsonar.sources=.
                    '''
                }
            }
        }

        stage('SonarQube Quality Gate') {
            when {
                expression { env.ENABLE_SONAR == "true" }
            }
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Docker Image') {
            when {
                expression { env.ENABLE_DOCKER == "true" }
            }
            steps {
                sh 'docker build -t ${DOCKER_IMAGE}:latest .'
            }
        }

        stage('Trivy Security Scan') {
            when {
                expression { env.ENABLE_DOCKER == "true" }
            }
            steps {
                sh 'trivy image --severity HIGH,CRITICAL --exit-code 1 ${DOCKER_IMAGE}:latest'
            }
        }

        stage('Deploy to Kubernetes') {
            when {
                expression { env.ENABLE_EKS == "true" }
            }
            steps {
                sh '''
                  kubectl apply -f kubernetes/
                  kubectl rollout status deployment --all
                '''
            }
        }

        stage('Monitoring Setup (Prometheus + Grafana)') {
            when {
                expression { env.ENABLE_EKS == "true" }
            }
            steps {
                sh '''
                  chmod +x monitoring/install.sh
                  ./monitoring/install.sh
                  kubectl apply -f monitoring/alerts/
                '''
            }
        }
    }

    post {
        success {
            echo "✅ ADEL CI PIPELINE COMPLETED SUCCESSFULLY"
        }
        failure {
            echo "❌ PIPELINE FAILED — CHECK LOGS"
        }
    }
}