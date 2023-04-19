#!/bin/bash

LOOP_PID=""

function finish {
  echo CLEANING!
  # do the process deletion here
  killall kubectl
  [ -n "${LOOP_PID}" ] && kill $LOOP_PID && echo "process with pid $LOOP_PID killed successfully"
  exit
}

trap finish INT EXIT
#trap finish ERR

# sleep command to test that the process interruption handling (Ctrl+C) works
sleep 2

make install-argocd-openshift
make devenv-k8s
make download-deps

echo "starting port-forward loop"
while true; do kubectl port-forward --namespace gitops svc/gitops-postgresql-staging 5432:5432 ; done&
LOOP_PID=$!
sleep 2

make start-e2e &
echo "Executing e2e tests"
make test-e2e
#killall kubectl
#killall goreman