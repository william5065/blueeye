#!groovy

node('jenkins-node-50') {
  
  stage('Check Code Style') {
    dir('project-patent-exam') {
      def CODE_STYLE_IMAGE = 'local-dtr.patsnap.com/patsnap/course-base-eslint';
      def WORKDIR = sh(returnStdout: true, script: 'pwd').trim()
 
      git branch: "develop", url: 'git@git.patsnap.com:course/project-patent-exam.git'
      sh "docker pull $CODE_STYLE_IMAGE"
      sh "docker run --rm -v $WORKDIR/:/data/ $CODE_STYLE_IMAGE /bin/bash -c 'cd /data/ ; eslint --ext .vue,.js,.es -f html -o code-style-report.html src/**/*; echo ok;'"
      
      /* publishHTML([
        allowMissing: false,
        alwaysLinkToLastBuild: false,
        keepAll: false,
        reportDir: '',
        reportFiles:'code-style-report.html',
        reportName: 'Code Style Report',
        reportTitles: ''
      ]) */
    }
  }
  stage('Check API Test') {
    dir('course-api-test') {
      def APITEST_IMAGE = 'apitest';
      def WORKDIR = sh(returnStdout: true, script: 'pwd').trim()

      git branch: "Patent_Exam", url: 'git@git.patsnap.com:course/course-api-test.git'

      sh "docker build -t $APITEST_IMAGE ."
      sh "docker run --rm --dns 192.168.3.108 -v $WORKDIR/html:/data/html $APITEST_IMAGE"

      /* publishHTML([
        allowMissing: false, 
        alwaysLinkToLastBuild: false, 
        keepAll: false, 
        reportDir: 'html', 
        reportFiles: 'Patent Exam.html', 
        reportName: 'API Test Report',
        reportTitles: ''
      ]) */

    }
  }
  stage('Check UI Test') {
    dir('auto-test') {
      def WORKDIR = sh(returnStdout: true, script: 'pwd').trim()
      def ROBOT_FRAMWORK = 'course/robotframwork'

      git branch: "master", url: 'git@git.patsnap.com:course/auto-test.git'

      sh "docker run --rm -v $WORKDIR/Patsnap/:/opt/testscripts/ -v $WORKDIR/report/:/data $ROBOT_FRAMWORK /bin/bash -c 'pybot /opt/testscripts/Web/A_Login.robot; echo ok;'"

      /* publishHTML([
        allowMissing: false,
        alwaysLinkToLastBuild: false,
        keepAll: false,
        reportDir: 'report',
        reportFiles:'report.html',
        reportName: 'UI Test Report',
        reportTitles: ''
      ]) */
    
    }
  }
  stage('Generate Report') {
    publishHTML([
      allowMissing: false,
      alwaysLinkToLastBuild: false,
      keepAll: false,
      reportDir: '',
      reportFiles:'project-patent-exam/code-style-report.html, course-api-test/html/Patent Exam.html, auto-test/report/report.html',
      reportName: 'Summary Report',
      reportTitles: 'Code Style Report, API Test Report, UI Test Report'
    ])
  }
}
