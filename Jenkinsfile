pipeline {
    agent {
        docker {
            image 'node:18.20.8-alpine'
        }
    }

    environment {
        NODE_ENV         = 'test'
        APP_DIR          = 'week5/friday/app'
        BUILD_DIR        = 'dist'
        APP_NAME         = 'kijanikiosk-payments'
        NPM_CONFIG_CACHE = "${WORKSPACE}/.npm"
        PKG_VERSION      = sh(script: "node -p \"require('./week5/friday/app/package.json').version\"", returnStdout: true).trim()
        GIT_SHORT        = "${GIT_COMMIT.substring(0, 7)}"
        ARTIFACT_VERSION = "${PKG_VERSION}-${GIT_SHORT}"
        NEXUS_URL        = 'http://172.17.0.1:8081/repository/npm-kijanikiosk/'
    }

    options {
        timeout(time: 15, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
        disableConcurrentBuilds()
    }

    stages {
        stage('Lint') {
            steps {
                dir(env.APP_DIR) {
                    sh 'node --version'
                    sh 'npm ci'
                    sh 'npm run lint'
                }
            }
        }

        stage('Build') {
            steps {
                dir(env.APP_DIR) {
                    sh 'npm run build'
                    sh 'test -d "$BUILD_DIR" && [ -n "$(ls -A "$BUILD_DIR")" ]'
                }
            }
        }

        stage('Verify') {
            parallel {
                stage('Test') {
                    steps {
                        dir(env.APP_DIR) { sh 'npm test' }
                    }
                    post {
                        always {
                            junit allowEmptyResults: true, testResults: 'week5/friday/app/test-results/*.xml'
                        }
                    }
                }
                stage('Security Audit') {
                    steps {
                        dir(env.APP_DIR) { sh 'npm audit --omit=dev --audit-level=high' }
                    }
                }
            }
        }

        stage('Archive') {
            steps {
                archiveArtifacts artifacts: "${APP_DIR}/${BUILD_DIR}/**", fingerprint: true, onlyIfSuccessful: true
            }
        }

        stage('Publish') {
            steps {
                dir(env.APP_DIR) {
                    withCredentials([usernamePassword(
                        credentialsId: 'wrong-id',
                        usernameVariable: 'NEXUS_USER',
                        passwordVariable: 'NEXUS_PASS'
                    )]) {
                        sh '''
                            set -e
                            set +x
                            trap "rm -f .npmrc" EXIT
                            TOKEN=$(printf '%s:%s' "$NEXUS_USER" "$NEXUS_PASS" | base64 | tr -d '\\n')
                            {
                              echo "registry=${NEXUS_URL}"
                              echo "${NEXUS_URL#http:}:_auth=${TOKEN}"
                              echo "always-auth=true"
                            } > .npmrc
                            npm version "${ARTIFACT_VERSION}" --no-git-tag-version
                            npm publish
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success { echo "Published ${APP_NAME}@${ARTIFACT_VERSION} to ${NEXUS_URL}" }
        failure { echo "Build FAILED: ${JOB_NAME} #${BUILD_NUMBER} - ${BUILD_URL}console" }
        changed { echo "Build status changed to ${currentBuild.currentResult} - ${JOB_NAME} #${BUILD_NUMBER}" }
    }
}
