#!/bin/bash
cleanup() {
	echo "caught signal, cleaning up" 
	export GOPATH=$GOPATH_ORG
        echo resetting old GOPATH=$GOPATH
}
trap 'cleanup' SIGTERM SIGINT SIGFPE 
shopt -u extglob; set +H
kubectx ${1:-minikube}
echo "Usage: $0 KO_DOCKER_REPO [ko.local|default:=gcr.io/plucky-door-2002008]" 
KO_DOCKER_REPO=${1:-grc.io/plucky-door-200208}
mkdir -p ~/go/src/knative.dev/
cd ~/go/src/knative.dev/
export PROJECT_ID=$(gcloud config get-value core/project)
export KO_DOCKER_REPO="gcr.io/${PROJECT_ID}"
GOPATH_ORG=$GOPATH
export GOPATH=$GOPATH:~/go/src/knative.dev/eventing-contrib
[ ! -d eventing-contrib ] && git clone https://github.com/knative/eventing-contrib.git
cd eventing-contrib
git pull
cd ~/go/src/knative.dev/eventing-contrib/cmd/heartbeats
go get github.com/google/ko/cmd/ko
sleep 2
# go get -u github.com/google/ko/cmd/ko
ko publish .
sleep 5
echo heartbeat source logs
kubectl logs --tail=50 -l eventing.knative.dev/source=heartbeats-sender 
echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
echo heartbeat receiver logs
kubectl logs --tail=50 -l serving.knative.dev/service=heartbeats-receiver -c user-container -f
