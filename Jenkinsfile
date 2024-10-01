#!groovy
pipeline {

  agent {
    node {
      label 'scmm'
    }
  }

  stages {

    stage('Set Version') {
      when {
        branch pattern: 'release/*', comparator: 'GLOB'
      }
      steps {
        // fetch all remotes from origin
        sh 'git config --replace-all "remote.origin.fetch" "+refs/heads/*:refs/remotes/origin/*"'
        sh 'git fetch --all'

        // checkout, reset and merge
        sh "git checkout ${env.BRANCH_NAME}"
        sh 'git checkout main'
        sh 'git reset --hard origin/main'
        sh "git merge --ff-only ${env.BRANCH_NAME}"

        // set tag
        tag releaseVersion
      }
    }

    stage('Build') {
      steps {
        script {
          image = docker.build("scmmanager/java-build")
        }
      }
    }

    stage('Deployment') {
      when {
        branch pattern: 'release/*', comparator: 'GLOB'
      }
      steps {
        script {
          docker.withRegistry('', 'cesmarvin-dockerhub-access-token') {
            image.push(releaseVersion)
            image.push("latest")
          }
        }
      }
    }

    stage('Update Repository') {
      when {
        branch pattern: 'release/*', comparator: 'GLOB'
      }
      steps {
        sh 'git checkout main'

        // push changes back to remote repository
        authGit 'SCM-Manager', 'push origin main --tags'
        authGit 'SCM-Manager', "push origin :${env.BRANCH_NAME}"
      }
    }
    
    stage('Update GitHub') {
      when {
        branch pattern: 'release/*', comparator: 'GLOB'
	    expression { return isBuildSuccess() }
      }
      steps {
        sh 'git checkout main'
        
        // push changes to GitHub
        authGit 'cesmarvin', "push -f https://github.com/scm-manager/java-build main --tags"
      }
    }
  }

}

def image

String getReleaseVersion() {
  if (env.BRANCH_NAME.startsWith("release/")) {
    return env.BRANCH_NAME.substring("release/".length())
  }
  return "latest"
}

void tag(String version) {
  String message = "release version ${version}"
  sh "git -c user.name='CES Marvin' -c user.email='cesmarvin@cloudogu.com' tag -m '${message}' ${version}"
}

boolean isBuildSuccess() {
  return currentBuild.result == null || currentBuild.result == 'SUCCESS'
}

void authGit(String credentials, String command) {
  withCredentials([
    usernamePassword(credentialsId: credentials, usernameVariable: 'AUTH_USR', passwordVariable: 'AUTH_PSW')
  ]) {
    sh "git -c credential.helper=\"!f() { echo username='\$AUTH_USR'; echo password='\$AUTH_PSW'; }; f\" ${command}"
  }
}
