# Development

Modified from https://github.com/shashi198/webapp/blob/master/project.zip and https://medium.com/the-devops-ship/ci-cd-pipeline-using-jenkins-and-git-both-running-in-docker-containers-deployed-using-docker-6825fe81b738 originally.

To start the environment, execute:

$ ./setup.sh

This starts:
 * jenkins (bindmounted to host at http://localhost:8090)
 * git server (from https://github.com/jkarlosb/git-server-docker) to store the webapp source code
 * webapp (bindmounted to host at http://localhost:8091)

After running `setup.sh`, it will create a webapp repo that you can commit back to (pushing to the
bare git repo under git-server/repos/webapp.git). When you commit, jenkins will pick up changes,
build them, and deploy the new docker container (accessible at http://localhost:8091 on the host).

## TODO

 1. change host ports in one place if practical
 1. trigger first jenkins job from setup.sh
 1. add CI
 1. update webapp source and commit back
