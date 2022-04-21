#!/usr/bin/env bash

function error_handler() {
  >&2 echo "Exited with BAD EXIT CODE '${2}' in ${0} script at line: ${1}."
  exit "$2"
}
trap 'error_handler ${LINENO} $?' ERR
set -o errtrace -o errexit -o nounset -o pipefail

set -x

if ! command -v docker >/dev/null ; then
  >&2 echo "ERROR: 'docker' is required to run this. Please install it. https://docs.docker.com/get-docker/"
  exit 1
fi

if ! command -v git >/dev/null ; then
  >&2 echo "ERROR: 'git' is required to run this. Please install it. https://git-scm.com/book/en/v2/Getting-Started-Installing-Git"
  exit 1
fi

if [[ ! -d webapp ]]; then
  git clone git-server/repos/webapp.git
fi

if [[ ! -d git-server ]]; then
  >&2 echo "ERROR: run this script from the project root, where git-server and jenkins are located"
  exit 1
fi

export JENKINS_HOST_PORT=8090
export WEBAPP_HOST_PORT=8091

function wait_for_job_to_be_created_in_jenkins() {
  local attempts=0

  while true ; do
    if curl -s --fail "http://localhost:${JENKINS_HOST_PORT}/job/Webapp_Pipeline_Deploy"; then
      break;
    elif [[ "$attempts" -gt 100 ]]; then
      >&2 echo "ERROR: could not find job in jenkins after 100 attempts"
      exit 1
    else
      attempts=$(( attempts + 1 ))
      echo "waiting for job to be created in jenkins. attempt: $attempts"
      sleep 1
    fi
  done
}

function wait_for_webapp_to_be_deployed() {
  local attempts=0

  while true ; do
    if curl -s --fail "http://localhost:${WEBAPP_HOST_PORT}"; then
      break;
    elif [[ "$attempts" -gt 100 ]]; then
      >&2 echo "ERROR: could not hit webapp after 100 attempts"
      exit 1
    else
      attempts=$(( attempts + 1 ))
      echo "waiting for webapp to come online. attempt: $attempts"
      sleep 1
    fi
  done
}

if curl -s --fail "http://localhost:${WEBAPP_HOST_PORT}"; then
  >&2 echo "ERROR: webapp is already running. this is not expected"
  exit 1
fi

cp ~/.ssh/id_rsa.pub "${PWD}/git-server/keys"
docker-compose up -d

# set up keys in the git server from jenkins and host
docker-compose restart git-server
jenkins_public_key=$(docker exec -it jenkins cat /root/.ssh/id_rsa.pub)
docker exec  git-server sh -c "echo $jenkins_public_key >> /home/git/.ssh/authorized_keys"
docker exec  git-server sh -c "chmod 700 /home/git/.ssh"
docker exec  git-server sh -c "chmod 600 /home/git/.ssh/*"
docker exec jenkins /bin/bash -c "chmod 700 /root/.ssh"
docker exec jenkins /bin/bash -c "chmod 600 /root/.ssh/*"

# FIXME: sleep
docker exec jenkins /bin/bash -c " sleep 10 && ssh-keyscan -p 22 git-server >> ~/.ssh/known_hosts"

# need to wait until it actually runs the pipeline-create.groovy before removing it.
wait_for_job_to_be_created_in_jenkins
docker exec jenkins /bin/bash -c "rm -rf /var/jenkins_home/init.groovy.d/pipeline-create.groovy"

# kick off build, which will deploy webapp
curl --fail -X POST http://localhost:8090/job/Webapp_Pipeline_Deploy/build

wait_for_webapp_to_be_deployed
