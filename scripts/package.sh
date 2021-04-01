#!/usr/bin/env bash

. scripts/common.sh

echo -e "${RS}${BLUE} Cleaning and preparing..."
find . -iname "*.tgz" -type f | grep -v 'docs/' | xargs rm

echo -e "${RS}${BLUE} Generating docs...${RS}"
scripts/generate_docs.sh
RET=$?

echo -e "${RS}${BLUE} Linting and checking...${RS}"
scripts/lint.sh
RET=$?

echo -e "${RS}${BLUE} Packaging charts... ${RS}"
helm package .
RET=$?

if [[ "${RET}" == 0 ]]; then
    helm repo index .

    echo -e "Copying chart packages and index to docs ${RS}"
    # rm -f docs/*.tgz
    rm -f docs/*.yaml
    mv ./*.tgz docs/
    mv ./index.yaml docs/

    echo -e "${BLUE} Now commit and push charts and docs! ${RS}"
else
    echo -e "${RED}Tests failed, charts not packaged! ${RS}"
fi
