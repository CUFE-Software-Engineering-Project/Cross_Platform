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
                      --target=lint \
                      --cache=true \
                      --cache-ttl=24h
                  '''
                } catch (err) {
                  echo "❌ Lint stage failed: ${err}"
                  currentBuild.result = 'UNSTABLE'
                }
              }
            }
          }
        }
        
        stage('Kaniko: Test image') {
          steps {
            container('kaniko') {
              script {
                sh '''
                  echo "Kaniko building test target (no push)..."
                  /kaniko/executor \
                    --context=. \
                    --dockerfile=Dockerfile \
                    --no-push \
                    --target=test \
                    --cache=true \
                    --cache-ttl=24h
                '''
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
                        /kaniko/executor \
                            --context=$(pwd) \
                            --dockerfile=Dockerfile.ci \
                            --destination=${DOCKER_IMAGE}:build-${BUILD_TAG} \
                            --tarPath=/workspace/image.tar \
                            --cache=true \
                            --cache-ttl=24h \
                            --target=build-apk
                        '''
                    }
                }
            }
        }
        stage('Extract APK from Image') {
            steps {
                container('kaniko') {
                    script {
                        sh '''
                            echo "📤 Extracting APK from Docker image..."
                            
                            # Create extraction directory
                            mkdir -p /workspace/extracted
                            cd /workspace/extracted
                            
                            # Extract the image tar
                            echo "Extracting image layers..."
                            tar -xf /workspace/image.tar
                            
                            # Find the layer containing the APK
                            echo "Searching for APK in layers..."
                            APK_FOUND=false
                            
                            for layer_dir in */; do
                                if [ -f "${layer_dir}layer.tar" ]; then
                                    echo "Checking layer: ${layer_dir}"
                                    
                                    # Check if this layer contains the APK
                                    if tar -tf "${layer_dir}layer.tar" 2>/dev/null | grep -q "${APK_PATH}"; then
                                        echo "✅ Found APK in layer: ${layer_dir}"
                                        
                                        # Extract the APK
                                        tar -xf "${layer_dir}layer.tar" "${APK_PATH}"
                                        
                                        # Move to workspace with build tag
                                        mv "${APK_PATH}" /workspace/app-release-${BUILD_TAG}.apk
                                        
                                        APK_FOUND=true
                                        break
                                    fi
                                fi
                            done
                            
                            if [ "$APK_FOUND" = false ]; then
                                echo "❌ APK not found in any layer!"
                                echo "Searching for any .apk files..."
                                
                                for layer_dir in */; do
                                    if [ -f "${layer_dir}layer.tar" ]; then
                                       tar -tf "${layer_dir}layer.tar" 2>/dev/null | grep "\\.apk$" || true
                                    fi
                                done
                                
                                exit 1
                            fi
                            
                            # Verify APK was extracted
                            if [ ! -f "/workspace/app-release-${BUILD_TAG}.apk" ]; then
                                echo "❌ APK file not found after extraction!"
                                exit 1
                            fi
                            
                            echo "✅ APK extracted successfully!"
                            ls -lh /workspace/app-release-${BUILD_TAG}.apk
                            
                            # Get APK size for reporting
                            APK_SIZE=$(ls -lh /workspace/app-release-${BUILD_TAG}.apk | awk '{print $5}')
                            echo "APK Size: ${APK_SIZE}"
                            
                            # Cleanup
                            echo "Cleaning up temporary files..."
                            cd /workspace
                            rm -rf extracted image.tar
                            
                            echo "✅ Extraction complete!"
                        '''
                    }
                }
            }
        }

        stage('Publish to GitHub Release') {
            steps {
                container('kaniko') {
                    script {
                        withCredentials([string(credentialsId: "${GIT_CREDENTIALS}", variable: 'GITHUB_TOKEN')]) {
                            sh '''
                                echo "📤 Publishing APK to GitHub Releases..."
                                
                                # Install GitHub CLI
                                echo "Installing GitHub CLI..."
                                cd /tmp
                                wget -q https://github.com/cli/cli/releases/download/v2.40.0/gh_2.40.0_linux_amd64.tar.gz
                                tar -xzf gh_2.40.0_linux_amd64.tar.gz
                                cp gh_2.40.0_linux_amd64/bin/gh /usr/local/bin/
                                chmod +x /usr/local/bin/gh
                                rm -rf gh_2.40.0_linux_amd64*
                                
                                cd /workspace
                                
                                # Verify APK exists
                                if [ ! -f "app-release-${BUILD_TAG}.apk" ]; then
                                    echo "❌ APK file not found!"
                                    exit 1
                                fi
                                
                                # Get APK info
                                APK_SIZE=$(ls -lh app-release-${BUILD_TAG}.apk | awk '{print $5}')
                                APK_SIZE_BYTES=$(stat -f%z app-release-${BUILD_TAG}.apk 2>/dev/null || stat -c%s app-release-${BUILD_TAG}.apk)
                                
                                echo "APK Details:"
                                echo "  - File: app-release-${BUILD_TAG}.apk"
                                echo "  - Size: ${APK_SIZE} (${APK_SIZE_BYTES} bytes)"
                                
                                # Authenticate with GitHub
                                echo "Authenticating with GitHub..."
                                echo "${GITHUB_TOKEN}" | gh auth login --with-token
                                
                                # Create release notes
                                RELEASE_NOTES="## 📱 Flutter Mobile App - Build #${BUILD_TAG}

### 📥 Download APK
Click below to download the latest version of the app:
- **[app-release-${BUILD_TAG}.apk](https://github.com/CUFE-Software-Engineering-Project/Cross_Platform/releases/download/v${BUILD_TAG}/app-release-${BUILD_TAG}.apk)** (${APK_SIZE})

### 📊 Build Information
| Item | Value |
|------|-------|
| **Build Number** | #${BUILD_TAG} |
| **Build Date** | $(date '+%Y-%m-%d %H:%M:%S UTC') |
| **Commit Hash** | \`${COMMIT_SHA}\` |
| **APK Size** | ${APK_SIZE} |
| **Docker Image** | \`${DOCKER_IMAGE}:build-${BUILD_TAG}\` |

### 📝 Commit Message
\`\`\`
${COMMIT_MSG}
\`\`\`

### 📲 Installation Instructions
1. Download the APK file from the link above
2. On your Android device, go to **Settings** → **Security** → Enable **Unknown Sources**
3. Open the downloaded APK file
4. Follow the on-screen prompts to install
5. Launch the app and enjoy! 🚀

### 🔗 Links
- **Jenkins Build:** ${BUILD_URL}
- **Docker Image:** \`docker pull ${DOCKER_IMAGE}:build-${BUILD_TAG}\`
- **Repository:** https://github.com/CUFE-Software-Engineering-Project/Cross_Platform

---
*Built with ❤️ by Jenkins CI/CD Pipeline*"
                                
                                # Create GitHub release
                                echo "Creating GitHub release..."
                                gh release create "v${BUILD_TAG}" \
                                    app-release-${BUILD_TAG}.apk \
                                    --repo CUFE-Software-Engineering-Project/Cross_Platform \
                                    --title "v${BUILD_TAG} - Mobile App Release" \
                                    --notes "${RELEASE_NOTES}"
                                
                                echo "✅ APK published to GitHub Release!"
                                echo "📦 Release URL: https://github.com/CUFE-Software-Engineering-Project/Cross_Platform/releases/tag/v${BUILD_TAG}"
                                echo "📥 Direct Download: https://github.com/CUFE-Software-Engineering-Project/Cross_Platform/releases/download/v${BUILD_TAG}/app-release-${BUILD_TAG}.apk"
                            '''
                        }
                    }
                }
            }
        }

        stage('Archive as Jenkins Artifact') {
            steps {
                container('kaniko') {
                    script {
                        // Copy APK to Jenkins workspace for archiving
                        sh '''
                            echo "Copying APK to Jenkins workspace..."
                            cp /workspace/app-release-${BUILD_TAG}.apk ${WORKSPACE}/app-release-${BUILD_TAG}.apk
                            ls -lh ${WORKSPACE}/*.apk
                        '''
                    }
                }
                // Archive the APK
                script {
                    archiveArtifacts artifacts: '*.apk', fingerprint: true, allowEmptyArchive: false
                    echo "✅ APK archived at: ${env.BUILD_URL}artifact/app-release-${BUILD_TAG}.apk"
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
