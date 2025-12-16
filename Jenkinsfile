pipeline {
    agent { label 'jenkins-agent' }

    environment {
        DOCKER_IMAGE = "realshoy/swe-mobile"
        BUILD_TAG = "${BUILD_NUMBER}"
        DOCKER_REGISTRY_CREDENTIALS = 'dockerhub-credentials'
        KUBE_CONFIG_CREDENTIALS = 'kubeconfig-file'
        EMAIL_RECIPIENTS = 'asxcchcv@gmail.com'
        APK_PATH = "/app/build/app/outputs/flutter-apk/app-release.apk" 
        JENKINS_EMAIL = 'asxcchcv@gmail.com'
        GIT_CREDENTIALS = 'github-token'
    }

    stages {
        
        stage("SCM Checkout") {
            steps {
                script {
                    checkout([
                        $class: 'GitSCM',
                        branches: [[name: '*/save_dev_changes']],
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


        stage('Inject Android Secrets') {
            steps {
                withCredentials([
                    file(credentialsId: 'android-release-jks', variable: 'RELEASE_JKS'),
                    file(credentialsId: 'google-services-json', variable: 'GOOGLE_JSON'),
                    file(credentialsId: 'android-key-properties', variable: 'KEY_PROPS'),
                    file(credentialsId: 'android-debug-keystore', variable: 'DEBUG_KEYSTORE')
                ]) {
                sh '''
                    cp "$RELEASE_JKS" android/app/release.jks
                    cp "$GOOGLE_JSON" android/app/google-services.json
                    cp "$KEY_PROPS" android/key.properties
                    cp "$DEBUG_KEYSTORE" android/app/debug.keystore
                '''
                }
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


        stage('Docker: Build APK Image') {
    steps {
        container('docke') {
            script {
                // Add credentials binding
                withCredentials([usernamePassword(
                    credentialsId: "${DOCKER_REGISTRY_CREDENTIALS}", // Create this in Jenkins
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                )]) {
                    sh '''
                        echo "🐳 Starting Docker daemon..."
                        dockerd-entrypoint.sh &
                        
                        # Wait for Docker daemon to be ready
                        echo "⏳ Waiting for Docker daemon..."
                        for i in $(seq 1 60); do
                            if docker info >/dev/null 2>&1; then
                                echo "✅ Docker daemon is ready!"
                                break
                            fi
                            echo "Waiting... ($i/60)"
                            sleep 2
                        done
                        
                        if ! docker info >/dev/null 2>&1; then
                            echo "❌ Docker daemon failed to start"
                            exit 1
                        fi
                        
                        echo "🧹 Cleaning workspace..."
                        if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
                            cp build/app/outputs/flutter-apk/app-release.apk ./app-release.apk
                            echo "✅ APK copied"
                        fi
                        rm -rf build/.dart_tool android/.gradle android/app/build || true
                        
                        echo "📊 Workspace size: $(du -sh . | cut -f1)"
                        
                        echo "🔐 Docker login..."
                        echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
                        
                        echo "🐳 Building Docker image..."
                        docker build \
                            --target=build-apk \
                            --build-arg BUILD_TAG=${BUILD_TAG} \
                            --tag ${DOCKER_IMAGE}:build-${BUILD_TAG} \
                            --file Dockerfile \
                            .
                        
                        echo "✅ Docker image built successfully!"
                        
                        echo "📤 Pushing image..."
                        docker push ${DOCKER_IMAGE}:build-${BUILD_TAG}
                        
                        echo "✅ Complete!"
                    '''
                }
            }
        }
    }
}

stage('Extract APK from Image') {
    steps {
        container('docke') {
            script {
                sh '''
                    echo "📤 Extracting APK from Docker image..."
                    
                    # Create temporary container
                    CONTAINER_ID=$(docker create ${DOCKER_IMAGE}:build-${BUILD_TAG})
                    
                    # Find APK in container
                    echo "Searching for APK file in container..."
                    APK_PATH=$(docker export ${CONTAINER_ID} | tar -t | grep -E "app-release\\.apk$" | head -n 1)
                    
                    if [ -z "$APK_PATH" ]; then
                        echo "❌ No APK found in container!"
                        echo "Available .apk files:"
                        docker export ${CONTAINER_ID} | tar -t | grep "\\.apk$" || echo "No APK files found"
                        docker rm ${CONTAINER_ID}
                        exit 1
                    fi
                    
                    echo "✅ Found APK at: ${APK_PATH}"
                    
                    # Copy APK from container
                    docker cp ${CONTAINER_ID}:/${APK_PATH} ./app-release-${BUILD_TAG}.apk
                    
                    # Cleanup
                    docker rm ${CONTAINER_ID}
                    
                    echo "✅ APK extracted successfully!"
                    ls -lh ./app-release-${BUILD_TAG}.apk
                '''
            }
        }
    }
}
 stage('Publish to GitHub Release') {
    steps {
        container('docke') {
            script {
                withCredentials([usernamePassword(
                    credentialsId: "${GIT_CREDENTIALS}", 
                    usernameVariable: 'GIT_USERNAME',
                    passwordVariable: 'GITHUB_TOKEN'
                )]) {
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
                        
                        cd ${WORKSPACE}
                        
                        # Verify APK exists
                        if [ ! -f "app-release-${BUILD_TAG}.apk" ]; then
                            echo "❌ APK file not found!"
                            exit 1
                        fi
                        
                        # Get APK info
                        APK_SIZE=$(ls -lh app-release-${BUILD_TAG}.apk | awk '{print $5}')
                        APK_SIZE_BYTES=$(stat -c%s app-release-${BUILD_TAG}.apk 2>/dev/null || stat -f%z app-release-${BUILD_TAG}.apk)
                        
                        echo "APK Details:"
                        echo "  - File: app-release-${BUILD_TAG}.apk"
                        echo "  - Size: ${APK_SIZE} (${APK_SIZE_BYTES} bytes)"
                        
                        # Get commit info
                        COMMIT_SHA=$(git rev-parse HEAD 2>/dev/null || echo "Unknown")
                        COMMIT_MSG=$(git log -1 --pretty=%B 2>/dev/null | head -n 1 || echo "No commit message")
                        BUILD_DATE=$(date '+%Y-%m-%d %H:%M:%S UTC')
                        
                        echo "✅ GitHub authentication ready"
                        
                        # Create release notes
                        cat > /tmp/release-notes.md << EOF
## 📱 Flutter Mobile App - Build #${BUILD_TAG}

### 📥 Download APK
- **[app-release-${BUILD_TAG}.apk](https://github.com/CUFE-Software-Engineering-Project/Cross_Platform/releases/download/v${BUILD_TAG}/app-release-${BUILD_TAG}.apk)** (${APK_SIZE})

### 📊 Build Information
| Item | Value |
|------|-------|
| **Build Number** | ${BUILD_TAG} |
| **Build Date** | ${BUILD_DATE} |
| **Commit** | ${COMMIT_SHA} |
| **APK Size** | ${APK_SIZE} |

### 📝 Commit Message
${COMMIT_MSG}

### 📲 Installation Instructions
1. Download the APK file from the link above
2. Enable Unknown Sources on your Android device
3. Install and enjoy! 🚀

### 🔗 Links
- Jenkins Build: ${BUILD_URL}
- Docker Image: ${DOCKER_IMAGE}:build-${BUILD_TAG}

---
*Built with Jenkins CI/CD*
EOF
                        
                        echo "Creating GitHub release..."
                        gh release create "v${BUILD_TAG}" \
                            app-release-${BUILD_TAG}.apk \
                            --repo CUFE-Software-Engineering-Project/Cross_Platform \
                            --title "v${BUILD_TAG} - Mobile App Release" \
                            --notes-file /tmp/release-notes.md || {
                                echo "⚠️ Release exists, uploading APK..."
                                gh release upload "v${BUILD_TAG}" \
                                    app-release-${BUILD_TAG}.apk \
                                    --repo CUFE-Software-Engineering-Project/Cross_Platform \
                                    --clobber
                            }
                        
                        rm -f /tmp/release-notes.md
                        
                        echo "✅ APK published to GitHub Release!"
                        echo "📦 https://github.com/CUFE-Software-Engineering-Project/Cross_Platform/releases/tag/v${BUILD_TAG}"
                    '''
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
