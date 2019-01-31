#!/bin/bash

. scripts/common.sh

function lint_chart() {
  chart_name=$1
  chart_file=$2

  echo -e "==> ${GREEN}Linting $chart_name...${RS}"
  output=`helm lint $chart_file --debug 2> /dev/null`
  if [ $? -ne 0 ]; then
    echo -e "===> ${RED} Linting errors for chart $chart_name ${RS}"
    echo -e "$output" | grep "\\["
    exit 1
  fi
  echo -e "$output" | grep "\\["
}

# Jenkins's working dir is not cp-helm-charts, so copy to tmp dir before linting
if [[ $JENKINS_HOME ]]; then
  rm -rf /tmp/cp-helm-charts
  cp -R . /tmp/cp-helm-charts
  cd /tmp/cp-helm-charts
fi

lint_chart cp-helm-charts .

for chart in `ls -1 charts`; do
  lint_chart $chart charts/$chart
done

echo -e "==> ${GREEN} No linting errors${RS}"
