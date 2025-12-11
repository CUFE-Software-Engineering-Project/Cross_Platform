pipeline {
    agent { label 'jenkins-agent' }

    environment {
        DOCKER_IMAGE = "realshoy/swe-mobile"
        BUILD_TAG = "${BUILD_NUMBER}"
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
                        branches: [[name: '*/main']],
                        userRemoteConfigs: [[
                            url: 'https://github.com/CUFE-Software-Engineering-Project/Cross_Platform.git',
                            credentialsId: "${GIT_CREDENTIALS}"
                        ]]
                    ])
                }
                sh '''
                    ls # for testing
                ''' 
            }
        }

        stage('Prepare Kaniko auth') {
            steps {
                container('kaniko') {
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_REGISTRY_CREDENTIALS}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh '''
                          echo "Writing /kaniko/.docker/config.json for Kaniko auth"
                          mkdir -p /kaniko/.docker
                          cat > /kaniko/.docker/config.json <<EOF
{
  "auths": {
    "https://index.docker.io/v1/": {
      "auth": "$(echo -n ${DOCKER_USER}:${DOCKER_PASS} | base64 -w0)"
    }
  }
}
EOF
                        '''
                    }
                }
            }
        }

        stage('Kaniko: Lint image') {
          steps {
            container('kaniko') {
              script {
                try {
                  sh '''
                    echo "Kaniko building lint target (no push, no cache)..."
                    /kaniko/executor \
                      --context=. \
                      --dockerfile=Dockerfile \
                      --no-push \
                      --target=lint
                  '''
                } catch (err) {
                  echo "❌ Lint stage failed: ${err}"
                  currentBuild.result = 'UNSTABLE'
                }
              }
            }
          }
        }
        
  


        stage('Kaniko: Build-APK image (build & push)') {
            steps {
                container('kaniko') {
                    script {
                        sh '''
                        echo "Kaniko building build-apk target and pushing..."
                        /kaniko/executor \\
                            --context=\\$(pwd) \\
                            --dockerfile=\\$(pwd)/Dockerfile \\
                            --destination=${DOCKER_IMAGE}:build-${BUILD_TAG} \\
                            --cache=true \\
                            --cache-ttl=24h \\
                            --target=build-apk
                        '''
                    }
                }
            }
        }

        stage("E2E Testing") {
            steps {
                container('nodejs') {
                    script {
                        try {
                            sh '''
                                echo "Running Integration tests..."
                                # put your actual E2E commands here
                            '''
                        } catch (Exception e) {
                            echo "❌ E2E tests failed! Rolling back deployment..."
                            container('kubectl') {
                                withCredentials([file(credentialsId: "${KUBE_CONFIG_CREDENTIALS}", variable: 'KUBECONFIG')]) {
                                    sh '''
                                        kubectl rollout undo deployment/swe-react-deployment -n swe-twitter
                                        kubectl rollout status deployment/swe-react-deployment -n swe-twitter --timeout=5m
                                    '''
                                }
                            }
                            error("E2E tests failed and deployment was rolled back")
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            script {
                def recipients = env.COMMIT_EMAILS ?: env.JENKINS_EMAIL
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
                    to: recipients,
                    mimeType: 'text/html'
                )
            }
        }
        
        failure {
            script {
                def recipients = env.COMMIT_EMAILS ?: env.JENKINS_EMAIL
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
                    to: recipients,
                    mimeType: 'text/html'
                )
            }
        }
    
        always {
            echo "Pipeline completed."
        }
    }
}
