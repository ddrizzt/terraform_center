pipeline {

  agent { label 'catsbuildagent.non.stratus.nike.com' }

  options {
    buildDiscarder(logRotator(numToKeepStr: '20'))
    disableConcurrentBuilds()
  }

  stages {
    stage('Workspace Setup') {
      steps {
        sh """
          echo \"Downloading Terraform 0.10.6\"
          wget -q https://releases.hashicorp.com/terraform/0.10.6/terraform_0.10.6_linux_amd64.zip
          unzip -qo terraform_0.10.6_linux_amd64.zip
          chmod 755 terraform
        """
      }
    }

    stage('Terraform Init and Plan'){
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 's.lstm-builduser.455433697805', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
          sh '''
            echo "Get temporary credentials aws-cn"
            NO_RESET=1 source /usr/local/bin/temp_creds.sh 455433697805 cn-north-1 lstmBuildAgentRole aws-cn
            ./terraform init -backend-config=./backend.config
            ./terraform plan -out=terraform.plan -var-file=./terraform.tfvars
          '''
        }
      }
    }

    stage("Validate before Apply") {
      steps {
        input 'Are you sure? Review the output of the previous step before proceeding!'
      }
    }

    stage('TerraDeploy the xAccount Role') {
      steps {
        withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 's.lstm-builduser.455433697805', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
          sh """
            NO_RESET=1 source /usr/local/bin/temp_creds.sh 455433697805 cn-north-1 lstmBuildAgentRole aws-cn
            set -x
            ./terraform apply terraform.plan
          """
        }
      }
    }
  }

  post {
    always {
      deleteDir()
    }
  }
}
