# Development

Modified from https://github.com/shashi198/webapp/blob/master/project.zip
originally

https://medium.com/the-devops-ship/ci-cd-pipeline-using-jenkins-and-git-both-running-in-docker-containers-deployed-using-docker-6825fe81b738

To start the environment, execute:

$ docker-compose up -d

This starts both the Git SSH Server, as well as the Webapp.
The app is running at http://localhost:8082.

Copy your public SSH key in the ./git-server/keys directory. 
See https://github.com/jkarlosb/git-server-docker for more info on using the Git Server container.

