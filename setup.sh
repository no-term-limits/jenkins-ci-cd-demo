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

docker-compose up -d

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

keys=$(docker exec -it jenkins cat /root/.ssh/id_rsa.pub)

docker exec jenkins /bin/bash -c "chmod 700 /root/.ssh"

docker exec jenkins /bin/bash -c "chmod 600 /root/.ssh/*"

# need to wait until it actually runs teh pipeline-create.groovy before removing it.
# also it seems like it doesn't yet have the plugins installed when it runs default-user.groovy,
# so that script fails, though maybe we don't need it.
# FIXME: wait 'til scripts are done.
# docker-compose logs -f
wait_for_job_to_be_created_in_jenkins

docker exec jenkins /bin/bash -c "rm -rf /var/jenkins_home/init.groovy.d/default-user.groovy"

docker exec jenkins /bin/bash -c "rm -rf /var/jenkins_home/init.groovy.d/pipeline-create.groovy"

# FIXME
docker exec jenkins /bin/bash -c " ssh-keyscan -p 22 git-server >> ~/.ssh/known_hosts"

docker-compose restart git-server

docker exec  git-server sh -c "echo $keys >> /home/git/.ssh/authorized_keys"

docker exec  git-server sh -c "chmod 700 /home/git/.ssh"

docker exec  git-server sh -c "chmod 600 /home/git/.ssh/*"
