#!/usr/bin/env bash

# Bash "strict" mode
set -euo pipefail
IFS=$'\n\t'


repo=${repo:-$1}
version=${version:-latest}

echo "github release for repo: $repo version: $version" 1>&2

curl -s "https://api.github.com/repos/$repo/releases/latest" | grep browser_download_url | grep linux | grep amd64 | head -1 | cut -d':' -f2- | xargs curl -sL

