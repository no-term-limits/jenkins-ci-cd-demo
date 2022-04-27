# jenkins-ci-cd-demo

## Run it

To start the environment, make sure `docker ps` works, then grab the repo
and run the setup script:

    git clone https://github.com/no-term-limits/jenkins-ci-cd-demo.git
    cd jenkins-ci-cd-demo
    ./bin/setup

This starts:
 * jenkins (bound to host at http://localhost:8090)
 * gogs git server (bound to host at http://localhost:9090) to host the webapp source code
 * docker registry (bound to host at http://localhost:8092) (`curl http://localhost:8092/v2/webapp/manifests/1`)
 * webapp (bound to host at http://localhost:8091)

After running the setup script, it will initialize a webapp git repo (./webapp) that you can commit back to (`git push origin main` will push to gogs). When you commit, jenkins will pick up the changes via a gogs webhook, build them, and deploy the new webapp docker container (accessible at http://localhost:8091 on the host).

## Exercises for the reader

 1. After `bin/setup` runs to completion successfully, try updating the webapp source code. There is some text that is displayed prominently on the homepage that says "This is Version N of the Todos App." You could increment that number, commit and push, and see if it deploys your change successfully.
 2. Update the Jenkinsfile to add a stage that checks the code for lint issues. There's a helpful script in the `webapp/bin` directory.
 3. Update the Jenkinsfile to add a stage that checks for npm packages with security issues. There's another helpful script in `webapp/bin`.
 4. Update the Jenkinsfile so that the two stages you just added run in parallel
 5. Probably for another day: fix the security issue by upgrading react

## Tear it down

    ./bin/teardown

## TODO

 1. change host ports in one place if practical
 1. add CI

## Attributions

Modified from https://github.com/shashi198/webapp/blob/master/project.zip, https://medium.com/the-devops-ship/ci-cd-pipeline-using-jenkins-and-git-both-running-in-docker-containers-deployed-using-docker-6825fe81b738, and https://github.com/symfony-doge/gogs-docker-compose. 
