#!/usr/bin/env bash

function error_handler() {
  echo "Exited with BAD EXIT CODE '${2}' in ${0} script at line: ${1}."
  exit "$2"
}
trap 'error_handler ${LINENO} $?' ERR
set -o errtrace -o errexit -o nounset -o pipefail

set -x

if [[ ! -d webapp ]]; then
  git clone git-server/repos/webapp.git
fi

if [[ ! -d git-server ]]; then
  >&2 echo "ERROR: run this script from the project root, where git-server and jenkins are located"
  exit 1
fi

function wait_for_job_to_be_created_in_jenkins() {
  local attempts=0

  while true ; do
    if curl -s --fail "http://localhost:8090/job/Webapp_Pipeline_Deploy"; then
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

cp ~/.ssh/id_rsa.pub "${PWD}/git-server/keys"
docker-compose up -d

# set up keys in the git server from jenkins and host
keys=$(docker exec -it jenkins cat /root/.ssh/id_rsa.pub)
docker exec  git-server sh -c "echo $keys >> /home/git/.ssh/authorized_keys"
docker exec  git-server sh -c "chmod 700 /home/git/.ssh"
docker exec  git-server sh -c "chmod 600 /home/git/.ssh/*"
docker exec jenkins /bin/bash -c "chmod 700 /root/.ssh"
docker exec jenkins /bin/bash -c "chmod 600 /root/.ssh/*"

docker-compose restart git-server
docker exec jenkins /bin/bash -c " ssh-keyscan -p 22 git-server >> ~/.ssh/known_hosts"

# need to wait until it actually runs the pipeline-create.groovy before removing it.
wait_for_job_to_be_created_in_jenkins
docker exec jenkins /bin/bash -c "rm -rf /var/jenkins_home/init.groovy.d/pipeline-create.groovy"
