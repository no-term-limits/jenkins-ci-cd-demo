# jenkins-ci-cd-demo

## Run it

To start the environment, execute:

    git clone https://github.com/no-term-limits/jenkins-ci-cd-demo.git
    cd jenkins-ci-cd-demo
    ./bin/setup

This starts:
 * jenkins (bound to host at http://localhost:8090)
 * gogs git server (bound to host at http://localhost:9090) to host the webapp source code
 * docker registry (bound to host at http://localhost:8092) (`curl http://localhost:8092/v2/webapp/manifests/1`)
 * webapp (bound to host at http://localhost:8091)

After running the setup script, it will initialize a webapp git repo (./webapp) that you can commit back to (git push origin main will push to gogs). When you commit, jenkins will pick up changes, build them, and deploy the new webapp docker container (accessible at http://localhost:8091 on the host).

## Exercises for the reader

 1. After `bin/setup` runs to completion successfully, try updating the webapp source code. There is some text that is displayed prominently on the homepage that says "This is Version N the Todos App." You could increment that number, commit and push, and see if it deploys your change successfully.

 2. Update the Jenkinsfile to add a stage that checks the code for lint issues.

## Tear it down

    ./bin/teardown

## TODO

 1. change host ports in one place if practical
 1. add CI

## Attributions

Modified from https://github.com/shashi198/webapp/blob/master/project.zip, https://medium.com/the-devops-ship/ci-cd-pipeline-using-jenkins-and-git-both-running-in-docker-containers-deployed-using-docker-6825fe81b738, and https://github.com/symfony-doge/gogs-docker-compose. 
