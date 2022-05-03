#!groovy
pipeline {

  agent {
    node {
      label 'docker'
    }
  }

  stages {

    stage('Set Version') {
      when {
        branch pattern: 'release/*', comparator: 'GLOB'
      }
      steps {
        // fetch all remotes from origin
        sh 'git config "remote.origin.fetch" "+refs/heads/*:refs/remotes/origin/*"'
        sh 'git fetch --all'

        // checkout, reset and merge
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
          docker.withRegistry('', 'hub.docker.com-cesmarvin') {
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
        authGit 'cesmarvin-github', 'push origin main --tags'
        authGit 'cesmarvin-github', "push origin :${env.BRANCH_NAME}"
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

void authGit(String credentials, String command) {
  withCredentials([
    usernamePassword(credentialsId: credentials, usernameVariable: 'AUTH_USR', passwordVariable: 'AUTH_PSW')
  ]) {
    sh "git -c credential.helper=\"!f() { echo username='\$AUTH_USR'; echo password='\$AUTH_PSW'; }; f\" ${command}"
  }
}
