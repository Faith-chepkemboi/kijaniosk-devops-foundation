#!/bin/sh
VERSION=$(node -p "require('./package.json').version")
SHA=$(git rev-parse --short=7 HEAD)
echo "${VERSION}-${SHA}"
