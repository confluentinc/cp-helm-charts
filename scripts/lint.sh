#!/bin/bash
error=0
RED='\033[0;31m'
RS='\033[0m' # No Color
GREEN='\033[0;32m'

echo -e "==> ${GREEN}Linting cp-helm-charts..${RS}."

for chart in `ls -1 charts`; do
  echo -e "==> ${GREEN}Linting $chart...${RS}"
  #output=`helm lint . --debug --strict 2> /dev/null`
  output=`helm lint . --debug 2> /dev/null`
  if [ $? -ne 0 ]; then
    echo -e "===> ${RED} Liniting errors for chart $chart ${RS}"
    echo -e "$output" | grep "\\["
    exit 1
  fi
  echo -e "$output" | grep "\\["
done
echo -e "==> ${GREEN} No linting errors${RS}"

exit $error