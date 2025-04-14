#!/bin/bash
STATUS="$1"

curl "https://api.GitHub.com/repos/cul-it/bcl-up_server_container/statuses/$GIT_COMMIT" \
    -H "Content-Type: application/json" \
    -H "Authorization: token $GIT_ACCESS_TOKEN" \
    -X POST \
    -d "{\"state\": \"$STATUS\",\"context\": \"continuous-integration/jenkins\", \"description\": \"Jenkins\", \"target_url\": \"https://jenkins.library.cornell.edu/job/$JENKINS_PROJECT/$BUILD_NUMBER/console\"}"
