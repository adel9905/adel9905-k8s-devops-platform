pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "ap-south-1"
        CLUSTER_NAME       = "staging-demo"
        SONAR_PROJECT_KEY  = "k8s-devops-project"
        DOCKER_IMAGE       = "k8s-demo-app"
        TF_DIR             = "tf_code"
        K8S_NAMESPACE      = "trainxops"
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
                  docker --version
                  kubectl version --client
                  aws --version
                  trivy --version
                  sonar-scanner --version
                '''
            }
        }

        stage('Terraform Validate (CI SAFE)') {
            steps {
                dir("${TF_DIR}") {
                    sh '''
                      rm -rf .terraform .terraform.lock.hcl backend.tf
                      terraform init -backend=false
                      terraform validate
                    '''
                }
            }
        }

        stage('Configure kubeconfig') {
            steps {
                sh '''
                  aws eks update-kubeconfig \
                    --region ${AWS_DEFAULT_REGION} \
                    --name ${CLUSTER_NAME}

                  kubectl cluster-info
                  kubectl get nodes
                '''
            }
        }

        stage('SonarQube Code Scan') {
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

        stage('Build Docker Image') {
            steps {
                sh '''
                  docker build -t ${DOCKER_IMAGE}:latest .
                '''
            }
        }

        stage('Trivy Security Scan') {
            steps {
                sh '''
                  trivy image \
                    --severity HIGH,CRITICAL \
                    --exit-code 1 \
                    ${DOCKER_IMAGE}:latest
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                  echo "Applying Kubernetes manifests..."

                  kubectl apply -f kubernetes/namespace.yaml
                  kubectl apply -f kubernetes/limitrange.yaml
                  kubectl apply -f kubernetes/resourcequota.yaml
                  kubectl apply -f kubernetes/

                  echo "Waiting for deployments to be ready..."

                  for deploy in $(kubectl get deployments -n ${K8S_NAMESPACE} -o name); do
                    kubectl rollout status $deploy -n ${K8S_NAMESPACE}
                  done
                '''
            }
        }

        stage('Monitoring Setup (Prometheus + Grafana)') {
            steps {
                sh '''
                  chmod +x monitoring/install.sh
                  ./monitoring/install.sh
                '''
            }
        }
    }

    post {
        success {
            echo "✅ FULL DEVOPS PIPELINE COMPLETED SUCCESSFULLY"
        }
        failure {
            echo "❌ PIPELINE FAILED — CHECK LOGS"
        }
    }
}