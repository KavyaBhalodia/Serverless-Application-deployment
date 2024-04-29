pipeline{
    agent any
    tools {
       terraform 'terraform'
    }
    environment{
        AWS_ACCESS_KEY_ID = credentials('aws-credentials')
        AWS_SECRET_ACCESS_KEY = credentials('aws-credentials')
        region="us-west-2"
    }
     stages {
        stage("Variables"){
            steps{
                script{
                        def BRANCH_NAME = "${GIT_BRANCH.split("/")[1]}"
                        echo "${BRANCH_NAME}"
                        echo "${BUILD_NUMBER}"
                        echo "%region%"
                }
            }
        }
        stage("terraform commands"){
            steps{
                dir("Infrastructure"){
                    bat''' 
                    terraform init
                    terraform plan
                    terraform apply -auto-approve
                    '''
                    }
            }
        }
        stage("Build and S3"){
            steps{
                dir("frontend"){
                    bat 'npm run build'
                    bat 'aws s3 sync build s3://harshvardhan-personal'
                    }
            }
        }
    }
}