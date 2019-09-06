#!/bin/bash
cleanup() {
	echo "caught signal, cleaning up" 
	export GOPATH=$GOPATH_ORG
        echo resetting old GOPATH=$GOPATH
}
trap 'cleanup' SIGTERM SIGINT SIGFPE 
shopt -u extglob; set +H
. bashrc_alias 2>&1 >/dev/null
kubectx ${1:-minikube}
echo "Usage: $0 KO_DOCKER_REPO (ko.local|gcr.io/plucky-door-2002008)" 
KO_DOCKER_REPO=${1:-grc.io/plucky-door-200208}
cd ~/go/src/knative.dev/
export PROJECT_ID=$(gcloud config get-value core/project)
export KO_DOCKER_REPO="gcr.io/${PROJECT_ID}"
GOPATH_ORG=$GOPATH
export GOPATH=/Users/michaelmellouk/go:/Users/michaelmellouk/go/src/knative.dev/eventing-contrib
[ ! -d eventing-contrib ] && git clone https://github.com/knative/eventing-contrib.git
cd eventing-contrib
git pull

cd ~/go/src/knative.dev/eventing-contrib/cmd/heartbeats
#echo ko resolve -f heartbeats-sender.yaml heartbeats-receiver.yaml
#ko resolve -P -f heartbeats-sender.yaml 
#ko resolve -f heartbeats-receiver.yaml
# ko apply -L -f config/
#cat ../../cmd/heartbeats/main.go
#ko publish ../../cmd/heartbeats/main.go
ko publish --local .
sleep 5
kubectl logs --tail=50 -l serving.knative.dev/service=heartbeats-receiver -c user-container -f
