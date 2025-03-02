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

![image.png](attachment:046f84ca-5171-42e4-ad9a-88199b688910:image.png)

**Step 3: Create a Dockerfile for Jenkins**

Create a Dockerfile to customize the Jenkins image. The Dockerfile installs Docker CLI and Jenkins plugins like Blue Ocean and Docker Workflow, ensuring Jenkins has the necessary tools and integrations.

```bash
nano Dockerfile
```

![image.png](attachment:d74457de-3a58-444f-b529-c6f3ca284bb5:image.png)

![image.png](attachment:60e257c0-f3f6-463d-bd9b-c24c9f35ae18:image.png)

**Step 4: Build and Run the Jenkins Image**

Build the Jenkins image using the Dockerfile and run it.

```bash
docker build -t myjenkins-blueocean:2.492.1-1
```

![image.png](attachment:851599ad-2587-4038-b4ba-562cf4605298:image.png)

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

![image.png](attachment:71741365-0a48-4659-9518-375543ff5b47:image.png)

![image.png](attachment:80b5da07-a104-4da7-b555-4cabc73715bf:image.png)

![image.png](attachment:e4ec5165-44f1-4531-b501-7d75b284d0dc:image.png)

![image.png](attachment:197c07bf-7e82-45b0-ba4a-2b080911827a:image.png)

![image.png](attachment:88ab79b7-fa32-45b8-9dfb-d1f638b5f7ff:image.png)

**Part 2: Setting Up a Jenkins Agent**

**Step 1: Generate SSH Keys for the Agent**

Generate SSH keys to authenticate the Jenkins agent.

```bash
ssh-keygen -f ~/.ssh/jenkins_agent_key
```

![image.png](attachment:1fc8a7fd-1a1f-4cc9-9c0e-b7d660b851da:image.png)

**Step 2: Add the SSH Key to Jenkins Credentials**

Add the generated SSH public key to Jenkins credentials. Go to **Jenkins Dashboard > Manage Jenkins > Credentials** and add a new SSH credential.

![image.png](attachment:8b15f4aa-65f4-4d10-8a43-c4c0ea9c93a2:image.png)

![image.png](attachment:95a1bcc4-f6fc-415e-9f06-1e4cf320a7d3:image.png)

```bash
cat ~/.ssh/jenkins_agent_key
```

![image.png](attachment:80a61c2a-677a-4453-b013-0ab33d735389:image.png)

![image.png](attachment:53fc8156-0adb-489b-90da-787640ea8797:image.png)

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

![image.png](attachment:32f8a211-5b68-4181-ad7d-f0c146eb01ae:image.png)

![image.png](attachment:b239466a-dba2-4c50-a8a3-6ee47d0750cd:image.png)

**Step 5: Fill in the information in Jenkins to start and connect the agent, it is important to put the container's IP in the host**

![image.png](attachment:c777f019-1b6c-4dbb-9c35-51921007bb3f:image.png)

![image.png](attachment:b1ac0417-910c-4dd2-8ee4-0263aa3d8813:image.png)

![image.png](attachment:d2734502-2f47-4b32-80ac-6bbe03300aaf:image.png)

![image.png](attachment:02c59881-b833-4308-9b24-49bfac2239df:image.png)

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

![image.png](attachment:29f6d283-2706-48a7-a640-1b340c635c0c:image.png)

![image.png](attachment:570e6df9-80fb-4dde-b930-ef1854fadb7d:image.png)

**Step 2: Modify the Pipeline to Check for Existing Project**

Modify the pipeline to check if the project folder exists. If it does, delete it before cloning the repository.

![image.png](attachment:84a93a6b-9a51-46c6-954f-e8dc858f2323:image.png)

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

![image.png](attachment:ff946b9a-0eb9-4c23-b1b1-73b9f28fd1b8:image.png)

![image.png](attachment:db65c710-8ff3-433b-af0c-fbab6a89a100:image.png)

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

![image.png](attachment:0bcacaf9-6cda-4cf0-9a13-2be2cb3abe27:image.png)

**Step 4: Modify the Clone Stage to Use the Selected Branch**

Modify the clone stage to use the selected branch.

![image.png](attachment:415bfa7c-e548-4ea0-be93-da364d27d7ae:image.png)

![image.png](attachment:fd02b303-b7b3-40b1-8ffc-4647217c618c:image.png)

![image.png](attachment:35636996-7934-4326-b9df-9710e3408450:image.png)

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

![image.png](attachment:7523c9fe-b906-471e-841a-3e074972b5b7:image.png)

**Step 5: Move the Pipeline Script to an External File**

Move the pipeline script to an external file (`Jenkinsfile`) and reference it in the pipeline configuration.

![image.png](attachment:1ba8cd4d-074c-4bb7-b34c-fe78fcba840f:image.png)

![image.png](attachment:9be5f3d2-60fd-414c-bdc1-a301f1593eb2:image.png)

![image.png](attachment:964c05e3-e1ba-425d-b2e1-2793dfc0db6d:image.png)

![image.png](attachment:b998bf9e-cd50-49f4-8af1-1230dc47dddf:image.png)
