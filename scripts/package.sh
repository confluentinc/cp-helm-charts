#!/usr/bin/env bash
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RS='\033[0m' # reset

echo -e "${RS}${BLUE} Cleaning and preparing..."
find . -iname "*.tgz" -type f | grep -v 'docs/' | xargs rm

echo -e "${RS}${BLUE} Linting and checking...${RS}"
scripts/lint.sh
RET=$?

echo -e "${RS}${BLUE} Packaging charts... ${RS}"
helm package .
RET=$?

if [[ "${RET}" == 0 ]]; then
    helm repo index .

    echo -e "Copying chart packages and index to docs ${RS}"
    rm -f docs/*.tgz
    rm -f docs/*.yaml
    mv ./*.tgz docs/
    mv ./index.yaml docs/

    echo -e "${BLUE} Now commit and push charts and docs! ${RS}"
else
    echo -e "${RED}Tests failed, charts not packaged! ${RS}"
fi