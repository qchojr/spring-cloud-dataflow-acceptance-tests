#!/bin/bash


function generate_manifest() {
cat << EOF > ./skipper-manifest.yml

applications:
- name: skipper-server-$RANDOM
  timeout: 120
  path: ./skipper-server.jar
  memory: 1G
  buildpack: $JAVA_BUILDPACK
  services:
    - mysql_skipper
EOF
if [ $LOG_SERVICE_NAME ]; then
    cat << EOF >> ./skipper-manifest.yml
    - $LOG_SERVICE_NAME
EOF
fi
cat << EOF >> ./skipper-manifest.yml
  env:
    SPRING_APPLICATION_NAME: skipper-server
    SPRING_CLOUD_SKIPPER_SERVER_STRATEGIES_HEALTHCHECK.TIMEOUTINMILLIS: 300000
    SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[pws]_CONNECTION_URL: $SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_URL
    SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[pws]_CONNECTION_ORG: $SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_ORG
    SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[pws]_CONNECTION_SPACE: $SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SPACE
    SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[pws]_CONNECTION_DOMAIN: $SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_DOMAIN
    SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[pws]_CONNECTION_USERNAME: $SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_USERNAME
    SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[pws]_CONNECTION_PASSWORD: $SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_PASSWORD
    SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[pws]_CONNECTION_SKIP_SSL_VALIDATION: $SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SKIP_SSL_VALIDATION
    SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[pws]_DEPLOYMENT_DELETE_ROUTES: true
    SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[pws]_DEPLOYMENT_SERVICES: $SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_STREAM_SERVICES
    SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[pws]_DEPLOYMENT_ENABLE_RANDOM_APP_NAME_PREFIX: false
    SPRING_CLOUD_SKIPPER_SERVER_PLATFORM_CLOUDFOUNDRY_ACCOUNTS[pws]_DEPLOYMENT_APP_NAME_PREFIX: $SPRING_CLOUD_DEPLOYER_CLOUDFOUNDRY_SPACE
    SPRING_APPLICATION_JSON: '{ "spring": { "cloud": { "skipper": { "server": { "enableLocalPlatform": "false"} } } } }'

EOF

}

function push_application() {
  echo "============================="
  echo "skipper-manifest.yml contents..."
  cat skipper-manifest.yml
  cf push -f skipper-manifest.yml
  rm -f skipper-manifest.yml
}

download_skipper $PWD
generate_manifest
push_application
run_scripts "$PWD" "config.sh"
