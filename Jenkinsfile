def config = jobConfig {
    slackChannel = 'tools-eng'  // TODO: Change this when Viktor provides one
}

def job = {
    stage('Lint') {
        sh 'scripts/lint.sh'
    }
}

runJob config, job
