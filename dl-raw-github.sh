#!/usr/bin/env bash

# Bash "strict" mode
set -euo pipefail
IFS=$'\n\t'


repo=${repo:-$1}
version=${version:-master}
file=${file:-$2}

echo "download from repo: $repo version:$version file:$file" 1>&2

curl -sL "https://github.com/$repo/raw/$version/$file"
