#!/usr/bin/env bash
set -e

# Take environment variable GITHUB_TOKEN
# GITHUB_TOKEN for pulling private github repo

git config --global url."${GIT_HOST_SCHEME:-https}://${GIT_USER}:${GIT_TOKEN}@${GIT_HOST:-github.com}/".insteadOf "${GIT_HOST_SCHEME:-https}://${GIT_HOST:-github.com}/"