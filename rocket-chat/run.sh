#!/bin/sh

set -e

log_info() {
    time=$(date +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"level\":\"info\",\"time\":\"$time\",\"message\":\"$1\"}"
}

log_fatal() {
    time=$(date +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"level\":\"fatal\",\"time\":\"$time\",\"message\":\"$1\"}"
}

log_warn() {
    time=$(date +"%Y-%m-%dT%H:%M:%SZ")
    echo "{\"level\":\"warn\",\"time\":\"$time\",\"message\":\"$1\"}"
}

log_info "run rocket-chat mongodump"
log_info "mongodump rocket-chat database - start"

set +e
cd /tmp
mongodump --uri="${database_uri}" --archive=dump.gz --gzip

cat << EOF | gcloud auth activate-service-account --key-file=-
${bucket_service_account_key}
EOF
mv dump.gz "dump-$(date -I).gz"
gsutil cp dump-*.gz "${bucket_url}"
log_info "latest dump ${bucket_url} uploaded"

log_info "mongodump rocket-chat database - end"
