def config = jobConfig {
    slackChannel = 'devprod-notifications'
}

def job = {
    stage('Lint') {
        sh 'scripts/lint.sh'
    }
}

runJob config, job
