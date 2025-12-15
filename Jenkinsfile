pipeline {
    agent { label 'jenkins-agent' }
    
    environment {
        DOCKER_IMAGE = "realshoy/swe-frontend"
        BUILD_TAG = "${env.BUILD_NUMBER}"
        DOCKER_REGISTRY_CREDENTIALS = 'dockerhub-credentials' 
        KUBE_CONFIG_CREDENTIALS = 'kubeconfig-file' 
        EMAIL_RECIPIENTS = 'asxcchcv@gmail.com'
        JENKINS_EMAIL = 'asxcchcv@gmail.com'
        GIT_CREDENTIALS = 'github-token' 
    }
    
    stages {

        stage('Get Commit Info') {
            steps {
                script {
                    // Get the commit author's email
                    def commitEmail = sh(
                        script: "git --no-pager show -s --format='%ae' HEAD",
                        returnStdout: true
                    ).trim()
                    
                    // Validate email
                    if (commitEmail && commitEmail.contains('@')) {
                        env.COMMIT_EMAILS = commitEmail
                    } else {
                        echo "Warning: Could not get commit email, using default"
                        env.COMMIT_EMAILS = env.JENKINS_EMAIL
                    }
                    
                    echo "Email will be sent to: ${env.COMMIT_EMAILS}"
                }
            }
        }
        
        stage("SCM Checkout") {
            steps {
                script {
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: '*/prod']],
                        userRemoteConfigs: [[
                            url: 'https://github.com/CUFE-Software-Engineering-Project/SWE-twitter-Frontend.git',  
                            credentialsId: "${GIT_CREDENTIALS}"
                        ]]
                    ])
                    
                    dir('k8s-manifests') {
                        checkout([
                            $class: 'GitSCM',
                            branches: [[name: '*/main']],
                            userRemoteConfigs: [[
                                url: 'https://github.com/CUFE-Software-Engineering-Project/SWE-twitter-infra.git',  
                                credentialsId: "${GIT_CREDENTIALS}"
                            ]]
                        ])
                    }
                }
            }
        }

        stage("Linting") {
            steps {
                container('nodejs') {
                    script {
                        try {
                            sh '''
                                echo "Installing dependencies..."
                                npm i 

                                npm install --save-dev eslint-plugin-react-x
                                npm install --save-dev prettier eslint-plugin-prettier eslint-config-prettier
                                npm install --save-dev eslint-plugin-react-dom
                                npm install --save-dev \
                                              eslint \
                                              eslint-plugin-react \
                                              eslint-plugin-react-hooks \
                                              eslint-plugin-react-refresh \
                                              @eslint/js \
                                              typescript-eslint \
                                              prettier \
                                              eslint-plugin-prettier \
                                              eslint-config-prettier
                                echo "Running ESLint..."
                                npm run lint
                                
                                echo "Running Prettier check..."
                                npx prettier --check "src/**/*.{js,jsx,ts,tsx}"
                            '''
                        } catch (Exception e) {
                            echo "⚠️ Linting failed, but continuing pipeline execution..."
                            currentBuild.result = 'UNSTABLE'
                        }
                    }
                }
            }
        }

        stage("Building with Kaniko") {
            steps {
                container('kaniko') {
                    script {
                        // Create Docker config for authentication
                        withCredentials([usernamePassword(
                            credentialsId: "${DOCKER_REGISTRY_CREDENTIALS}",
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_PASS'
                        )]) {
                            sh '''
                                echo "Creating Docker config for Kaniko..."
                                mkdir -p /kaniko/.docker
                                cat > /kaniko/.docker/config.json <<EOF
{
"auths": {
    "https://index.docker.io/v1/": {
    "auth": "$(echo -n ${DOCKER_USER}:${DOCKER_PASS} | base64)"
    }
}
}
EOF
                            '''
                            
                           sh '''
                            /kaniko/executor \
                              --context=$(pwd) \
                              --dockerfile=Dockerfile \
                              --destination=${DOCKER_IMAGE}:${BUILD_TAG} \
                              --destination=${DOCKER_IMAGE}:latest \
                              --cache=true \
                              --cache-repo=docker.io/realshoy/swereactcache \
                              --cache-ttl=24h \
                              --compressed-caching=false \
                              --cleanup
                            '''
                        }
                    }
                }
            }
        }

        stage("Unit Testing") {
            steps {
                container('nodejs') {
                    sh """
                        echo "Running unit tests with Vitest..."
                        npm i
                        npx vitest run
                    """
                }
            }
        }

        stage("E2E Testing") {
            steps {
                container('nodejs') {
                    script {
                        sh """
                            echo "Installing dependencies..."
                            npm ci
                            
                            echo "Running Cypress E2E tests..."
                            npx cypress run
                        """
                    }
                }
            }
        }

        stage("Deploy to Kubernetes") {
            steps {
                container('kubectl') {
                    script {
                        sh """
                            echo "Updating deployment with new image..."
                            sed -i "s|image: .*swe-frontend.*|image: ${DOCKER_IMAGE}:${BUILD_TAG}|g" k8s-manifests/kubernetes/'React Frontend'/react-deployment.yaml
                            
                            echo "Applying Kubernetes manifest..."
                            kubectl apply -f k8s-manifests/kubernetes/'React Frontend'/react-deployment.yaml
                            
                            echo "Waiting for rollout to complete..."
                            kubectl rollout status deployment/swe-react-deployment -n swe-twitter --timeout=5m
                        """
                    }
                }
            }
        }        
    }

    post {
        success {
            steps {
                script {
                    def recipients = env.COMMIT_EMAILS ?: env.JENKINS_EMAIL
                    env.EMAIL_RECIPIENTS = recipients
                }
                emailext (
                    subject: "✅ Jenkins Backend Build SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                    body: """
                        <h2>Backend Build Successful! 🎉</h2>
                        <p><strong>Job:</strong> ${env.JOB_NAME}</p>
                        <p><strong>Build Number:</strong> ${env.BUILD_NUMBER}</p>
                        <p><strong>Build URL:</strong> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                        <p><strong>Docker Image:</strong> ${DOCKER_IMAGE}:${BUILD_TAG}</p>
                        <hr>
                        <p>The backend application has been successfully deployed to Kubernetes.</p>
                        <p><strong>Deployment:</strong> swe-node-deployment</p>
                        <p><strong>Namespace:</strong> swe-twitter</p>
                    """,
                    to: "${env.EMAIL_RECIPIENTS}",
                    mimeType: 'text/html'
                )
            }
        }
        
        failure {
            steps {
                script {
                    def recipients = env.COMMIT_EMAILS ?: env.JENKINS_EMAIL
                    env.EMAIL_RECIPIENTS = recipients
                }
                emailext (
                    subject: "❌ Jenkins Backend Build FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                    body: """
                        <h2>Backend Build Failed! ⚠️</h2>
                        <p><strong>Job:</strong> ${env.JOB_NAME}</p>
                        <p><strong>Build Number:</strong> ${env.BUILD_NUMBER}</p>
                        <p><strong>Build URL:</strong> <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
                        <p><strong>Console Output:</strong> <a href="${env.BUILD_URL}console">${env.BUILD_URL}console</a></p>
                        <hr>
                        <p>Please check the console output for error details.</p>
                    """,
                    to: "${env.EMAIL_RECIPIENTS}",
                    mimeType: 'text/html'
                )
            }
        }
        
        always {
            echo "Pipeline completed."
        }
    }
}
