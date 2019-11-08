#!/usr/bin/env bash
set -e

# Take environment variable GITHUB_TOKEN
# GITHUB_TOKEN for pulling private github repo

git config --global url."https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"