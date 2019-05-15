def config = jobConfig {
    slackChannel = 'tools-notifications'
}

def job = {
    stage('Lint') {
        sh 'scripts/lint.sh'
    }
}

runJob config, job
