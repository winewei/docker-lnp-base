#!/usr/bin/env bash
set -e

# Take environment variable NPM_TOKEN and GITHUB_TOKEN
# NPM_TOKEN for installing private module
# GITHUB_TOKEN for pulling private github repo
# then just yarn and git as your local dev environment (subject to the token permission)

echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" > ~/.npmrc
git config --global url."https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"