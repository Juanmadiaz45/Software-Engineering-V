# Docker - Jenkins

**Part 1: Setting Up Jenkins Controller in Docker**

**Step 1: Create a Docker Network for Jenkins**

Before running the Jenkins controller, create a Docker network named `jenkins`. This network will be used to connect the Jenkins controller and agent.

```bash
docker network create jenkins
```

![image](https://github.com/user-attachments/assets/69921c55-e478-48c3-8a3d-3b9a83055e1c)

**Step 2: Run Jenkins Controller in Docker**

Run the Jenkins controller using the `docker:dind` (Docker in Docker) image. This allows Jenkins to run Docker commands inside the container.

```bash
docker run \
  --name jenkins-docker \
  --rm \
  --detach \
  --privileged \
  --network jenkins \
  --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  --publish 2376:2376 \
  docker:dind \
  --storage-driver overlay2
```

![image](https://github.com/user-attachments/assets/3458c941-9557-4e7d-8e2e-a2678966dda6)

**Step 3: Create a Dockerfile for Jenkins**

Create a Dockerfile to customize the Jenkins image. The Dockerfile installs Docker CLI and Jenkins plugins like Blue Ocean and Docker Workflow, ensuring Jenkins has the necessary tools and integrations.

```bash
nano Dockerfile
```

![image](https://github.com/user-attachments/assets/c076a983-e121-44f5-ae77-dd453a7c21c0)

![image](https://github.com/user-attachments/assets/606f89b8-a5af-4cfb-b03c-039f59ac745d)

**Step 4: Build and Run the Jenkins Image**

Build the Jenkins image using the Dockerfile and run it.

```bash
docker build -t myjenkins-blueocean:2.492.1-1
```

![image](https://github.com/user-attachments/assets/c2633ba0-fb75-4038-aabe-f8fcf716e954)

```bash
docker run \
  --name jenkins-blueocean \
  --restart=on-failure \
  --detach \
  --network jenkins \
  --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client \
  --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 \
  --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  myjenkins-blueocean:2.492.1-1
```

```bash
docker exec jenkins-blueocean cat /var/jenkins_home/secrets/initialAdminPassword
```

**Step 5: Unlock Jenkins**

After running the Jenkins container, you need to unlock it using the initial admin password. The password can be found in the Jenkins logs or in the file `/var/jenkins_home/secrets/initialAdminPassword`.

![image](https://github.com/user-attachments/assets/b515d73b-3464-43bb-9151-cdbf9c0cd40d)

![image](https://github.com/user-attachments/assets/d8fc3b25-1187-4322-8952-9a9a52f39725)

![image](https://github.com/user-attachments/assets/860be3c5-a8b9-4fca-b7d5-0ce3b81fc0cf)

![image](https://github.com/user-attachments/assets/558172bf-2eff-4bb6-a735-3a4c91b8066f)

![image](https://github.com/user-attachments/assets/1a6e20b3-80cc-49d4-bc7d-a7e5e2206f11)

**Part 2: Setting Up a Jenkins Agent**

**Step 1: Generate SSH Keys for the Agent**

Generate SSH keys to authenticate the Jenkins agent.

```bash
ssh-keygen -f ~/.ssh/jenkins_agent_key
```

![image](https://github.com/user-attachments/assets/841cd8a1-3f33-4e6d-8627-463230b0d508)

**Step 2: Add the SSH Key to Jenkins Credentials**

Add the generated SSH public key to Jenkins credentials. Go to **Jenkins Dashboard > Manage Jenkins > Credentials** and add a new SSH credential.

![image](https://github.com/user-attachments/assets/a30c92f4-76e3-4b9f-96d2-628fce40314d)

![image](https://github.com/user-attachments/assets/d9e1a314-281a-4b61-a8d9-2a505b720300)

```bash
cat ~/.ssh/jenkins_agent_key
```

![image](https://github.com/user-attachments/assets/2a51a7e0-e55e-4177-aa12-6544cc562fa1)

![image](https://github.com/user-attachments/assets/0293afca-6702-40ae-8298-b90f007008e8)

**Step 3: Run the Jenkins Agent in Docker**

Run the Jenkins agent as a Docker container and connect it to the Jenkins controller using the SSH key.

```bash
cat ~/.ssh/jenkins_agent_key.pub
```

```bash
docker run -d --rm --name=agent1 -p 22:22 \
-e "JENKINS_AGENT_SSH_PUBKEY=AAAAC3NzaC1lZDI1NTE5AAAAIN4U95SNZCTB1cRw+RlmXbteD/CAkau+NFY/ajuuubcr" \
jenkins/ssh-agent:alpine-jdk17
```

![image](https://github.com/user-attachments/assets/02721e39-037a-41ab-b5db-215dc7238430)

![image](https://github.com/user-attachments/assets/8b20e490-c850-41f1-af68-957f4e0b392a)

**Step 5: Fill in the information in Jenkins to start and connect the agent, it is important to put the container's IP in the host**

![image](https://github.com/user-attachments/assets/744c9020-ba04-4adc-9d92-50e05ac95e81)

![image](https://github.com/user-attachments/assets/6a5f02e4-84a2-4db9-8750-8426be4303b0)

![image](https://github.com/user-attachments/assets/d5bd82fb-bbc8-43bb-b70d-718160fe8465)

![image](https://github.com/user-attachments/assets/a656cd45-c4d1-48ed-9e66-7363cc93184b)

**Part 3: Creating and Configuring Jenkins Pipelines**

**Step 1: Create a Basic Pipeline**

Create a pipeline that clones a repository, builds the project, runs tests, and packages the application.

```groovy
pipeline {
    agent any
    tools {
        maven 'Maven'
    }
    stages {
        stage('Clone') {
            steps {
                echo 'Clonando repositorio...'
                git 'https://github.com/jenkins-docs/simple-java-maven-app.git'
            }
        }
        
        stage('Build') {
            steps {
                echo 'Compilando el proyecto...'
                sh 'mvn -B clean compile'
            }
        }
        
        stage('Test') {
            steps {
                echo 'Ejecutando pruebas...'
                sh 'mvn -B test'
            }
        }
        
        stage('Package') {
            steps {
                echo 'Empaquetando el proyecto...'
                sh 'mvn -B package -DskipTests'
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline ejecutado exitosamente!'
        }
        failure {
            echo 'El pipeline ha fallado :('
        }
    }
}
```

![image](https://github.com/user-attachments/assets/1b857531-4248-492b-9709-a4e3bca8b01b)

![image](https://github.com/user-attachments/assets/922d8665-9043-4404-8513-61b1ecd3a702)

**Step 2: Modify the Pipeline to Check for Existing Project**

Modify the pipeline to check if the project folder exists. If it does, delete it before cloning the repository.

![image](https://github.com/user-attachments/assets/e3bd1032-55c4-4eea-a279-b23e96df6f46)

```groovy
pipeline {
    agent any
    
    tools {
        maven 'Maven'
    }
    
    stages {
        stage('Clone') {
            steps {
                echo 'Clonando repositorio...'
                git 'https://github.com/jglick/simple-maven-project-with-tests.git'
            }
        }
        
        stage('Build') {
            steps {
                echo 'Compilando el proyecto...'
                sh 'mvn -B clean compile'
            }
        }
        
        stage('Test') {
            steps {
                echo 'Ejecutando pruebas...'
                script {
                    try {
                        sh 'mvn -B test'
                    } catch (Exception e) {
                        echo 'Algunas pruebas fallaron, pero continuaremos con el pipeline'
                    }
                }
            }
        }
        
        stage('Package') {
            steps {
                echo 'Empaquetando el proyecto...'
                sh 'mvn -B package -DskipTests'
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline ejecutado exitosamente!'
            junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'
            archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
        }
        failure {
            echo 'El pipeline ha fallado :('
        }
    }
}
```

![image](https://github.com/user-attachments/assets/cf7bf6a2-4c65-479e-8826-66c1a368ecbe)

![image](https://github.com/user-attachments/assets/aaf5a990-fc1f-40ff-84d1-2165860fd8d5)

**Step 3: Add a Branch Parameter**

Add a parameter to the pipeline to allow selecting the branch for compilation.

```groovy
pipeline {
    agent any
    
    tools {
        maven 'Maven'
    }
    
    stages {
        stage('Preparar Workspace') {
            steps {
                echo 'Verificando si el proyecto ya existe...'
                script {
                    def folderExists = fileExists 'simple-maven-project-with-tests'
                    if (folderExists) {
                        echo 'La carpeta del proyecto existe. Eliminándola...'
                        sh 'rm -rf simple-maven-project-with-tests'
                    } else {
                        echo 'La carpeta del proyecto no existe.'
                    }
                }
            }
        }
        
        stage('Clone') {
            steps {
                echo 'Clonando repositorio desde Github...'
                sh 'git clone https://github.com/jglick/simple-maven-project-with-tests.git'
                sh 'cd simple-maven-project-with-tests'
            }
        }
        
        stage('Build') {
            steps {
                dir('simple-maven-project-with-tests') {
                    echo 'Compilando el proyecto con Maven...'
                    sh 'mvn -B clean compile'
                }
            }
        }
        
        stage('Test') {
            steps {
                dir('simple-maven-project-with-tests') {
                    echo 'Ejecutando pruebas con Maven...'
                    script {
                        try {
                            sh 'mvn -B test'
                        } catch (Exception e) {
                            echo 'Algunas pruebas fallaron, pero continuaremos con el pipeline'
                        }
                    }
                }
            }
        }
        
        stage('Package') {
            steps {
                dir('simple-maven-project-with-tests') {
                    echo 'Empaquetando el proyecto con Maven...'
                    sh 'mvn -B package -DskipTests'
                }
            }
        }
    }
    
    post {
        always {
            dir('simple-maven-project-with-tests') {
                junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'
            }
        }
        success {
            dir('simple-maven-project-with-tests') {
                echo 'Pipeline ejecutado exitosamente!'
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }
    }
}
```

![image](https://github.com/user-attachments/assets/9878af03-0b20-4d0a-8ce0-fe569c2daee9)

**Step 4: Modify the Clone Stage to Use the Selected Branch**

Modify the clone stage to use the selected branch.

![image](https://github.com/user-attachments/assets/40d4250d-8510-401b-9332-23176832af7d)

![image](https://github.com/user-attachments/assets/a638fb73-56ef-4361-9e98-105f6a55077e)

![image](https://github.com/user-attachments/assets/8b23e746-6ce9-4a3c-96a7-ea46c05ab3aa)

```groovy
pipeline {
    agent any
    
    tools {
        maven 'Maven'
    }
    
    parameters {
        choice(name: 'BRANCH', choices: ['master', 'junit-4.11'], description: 'Selecciona la rama que quieres compilar')
    }
    
    stages {
        stage('Preparar Workspace') {
            steps {
                echo 'Verificando si el proyecto ya existe...'
                script {
                    def folderExists = fileExists 'simple-maven-project-with-tests'
                    if (folderExists) {
                        echo 'La carpeta del proyecto existe. Eliminándola...'
                        sh 'rm -rf simple-maven-project-with-tests'
                    } else {
                        echo 'La carpeta del proyecto no existe.'
                    }
                }
            }
        }
        
        stage('Clone') {
            steps {
                echo "Clonando repositorio desde Github rama: ${params.BRANCH}..."
                sh "git clone -b ${params.BRANCH} https://github.com/jglick/simple-maven-project-with-tests.git"
                echo "Proyecto clonado desde la rama ${params.BRANCH} exitosamente!"
            }
        }
        
        stage('Build') {
            steps {
                dir('simple-maven-project-with-tests') {
                    echo 'Compilando el proyecto con Maven...'
                    sh 'mvn -B clean compile'
                }
            }
        }
        
        stage('Test') {
            steps {
                dir('simple-maven-project-with-tests') {
                    echo 'Ejecutando pruebas con Maven...'
                    script {
                        catchError(buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {
                            sh 'mvn -B test'
                        }
                    }
                }
            }
        }
        
        stage('Package') {
            steps {
                dir('simple-maven-project-with-tests') {
                    echo 'Empaquetando el proyecto con Maven...'
                    sh 'mvn -B package -DskipTests'
                }
            }
        }
    }
    
    post {
        always {
            script {
                def testResultsExist = fileExists('simple-maven-project-with-tests/target/surefire-reports/')
                if (testResultsExist) {
                    dir('simple-maven-project-with-tests') {
                        junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'
                    }
                } else {
                    echo 'No se encontraron resultados de pruebas, omitiendo la publicación de JUnit.'
                }
            }
        }
        success {
            dir('simple-maven-project-with-tests') {
                echo 'Pipeline ejecutado exitosamente!'
                echo "Se ha compilado correctamente la rama: ${params.BRANCH}"
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }
    }
}

```

Now, we can select the branch.

![image](https://github.com/user-attachments/assets/f3f47824-c8cf-4b8c-b040-997f5400681b)

**Step 5: Move the Pipeline Script to an External File**

Move the pipeline script to an external file (`Jenkinsfile`) and reference it in the pipeline configuration.

![image](https://github.com/user-attachments/assets/3e3739c9-7261-4045-bfe2-65ffc4eff0df)

![image](https://github.com/user-attachments/assets/50aca50b-3806-46e8-a648-dd4e6246715b)

![image](https://github.com/user-attachments/assets/a50d7209-4e83-4e6b-927d-97ee99cd42cf)

![image](https://github.com/user-attachments/assets/1607d5aa-884f-4bd6-83d0-e55732451816)
