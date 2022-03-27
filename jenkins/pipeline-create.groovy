import hudson.plugins.git.*
import jenkins.model.*
import hudson.security.*
import jenkins.*
import jenkins.hudson.*
import hudson.model.*
import hudson.triggers.SCMTrigger;

def scm = new GitSCM("ssh://git@git-server:22/git-server/repos/webapp.git")
scm.branches = [new BranchSpec("*/main")];

def flowDefinition = new org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition(scm, "Jenkinsfile")

def parent = Jenkins.instance
def job = new org.jenkinsci.plugins.workflow.job.WorkflowJob(parent, "Webapp_Pipeline_Deploy")

SCMTrigger trigger = new SCMTrigger("H/10 * * * *");
  job.addTrigger(trigger);
  trigger.start(job, true);

job.definition = flowDefinition

parent.reload()
