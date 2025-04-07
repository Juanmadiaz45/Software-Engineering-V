# SonarQube Integration with GitHub Actions - Complete Documentation

## 1. Introduction

This guide explains how to set up a complete SonarQube analysis pipeline using an Azure VM and GitHub Actions. We’ll learn how to deploy SonarQube in the cloud and connect it to our GitHub repository for automated code quality checks.

## 2. Prerequisites

Before starting, we'll need:

- An active Azure account  
- A GitHub repository with our code  
- Basic familiarity with Docker and YAML  

## 3. Implementation

### Creating the Azure Virtual Machine

We begin by setting up our cloud server to host SonarQube. In the Azure portal:

- Navigate to Virtual Machines and click "Create"  
- Select **Ubuntu Server 24.04 LTS** as the operating system  
- Choose the **Standard_D2s_v3** size (2 CPUs, 8GB RAM) - this provides enough resources for SonarQube to run smoothly  
- Under authentication, select **SSH public key** for secure access  
- In the networking section, make sure to open port **9000** for SonarQube access  
- Enable Trusted Launch security features including **Secure Boot** and **vTPM** for enhanced protection  
- Note the public IP address assigned to our VM (like `4.228.228.218` in our example)  

### Configuring Network Access

To allow GitHub Actions to communicate with our SonarQube instance:

- Go to the **Networking** section of the VM in Azure portal  
- Add a new inbound port rule:  
  - **Protocol**: TCP  
  - **Port range**: 9000  
  - **Priority**: 310  
  - **Name**: sonarqube-access  
- Save the rule - this will allow traffic to reach our SonarQube instance  

### Installing Docker and Docker Compose

With our VM ready, we need to install the container runtime:

- Connect to the VM via SSH  
- Update package lists  
- Install Docker  
- Start and enable Docker  
- Install Docker Compose by downloading the latest stable release  
- Make it executable

```bash
# Install Docker
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Deploying SonarQube

Now we'll set up SonarQube using Docker containers:

- Create a directory for the configuration  
- Create a `docker-compose.yml` file with the following content:  

```yml
version: '3.8'

services:
  sonarqube:
    image: sonarqube:lts-community
    container_name: sonarqube
    depends_on:
      - sonar_db
    ports:
      - "9000:9000"
    environment:
      SONARQUBE_JDBC_URL: jdbc:postgresql://sonar_db:5432/sonar
      SONARQUBE_JDBC_USERNAME: sonar
      SONARQUBE_JDBC_PASSWORD: sonar
      SONAR_SEARCH_JAVAOPTS: -Xmx512m -Xms512m
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
    networks:
      - sonarnet
    restart: unless-stopped

  sonar_db:
    image: postgres:13
    container_name: sonar_db
    environment:
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: sonar
      POSTGRES_DB: sonar
    volumes:
      - postgresql_data:/var/lib/postgresql/data
    networks:
      - sonarnet
    restart: unless-stopped

networks:
  sonarnet:
    driver: bridge

volumes:
  sonarqube_data:
  sonarqube_extensions:
  postgresql_data:
```

- Start the containers  
- Verify it's running  
- Access the web interface at `http://[OUR_VM_IP]:9000`  

### Configuring SonarQube for GitHub Integration

To connect SonarQube with our GitHub repository:

- Log in to SonarQube (default `admin/admin`)  
- Immediately change the admin password in **User > My Account > Security**  
- Generate an access token:  
  - Navigate to **User > My Account > Security**  
  - Click "Generate Tokens"  
  - Give it a descriptive name like "github-actions"  
  - Copy the generated token (we won’t see it again)  

### Setting Up GitHub Secrets

To securely store SonarQube credentials in our repository:

- Go to our GitHub repository **Settings**  
- Navigate to **Secrets > Actions**  
- Create a new secret named `SONAR_TOKEN` with the token we copied earlier  
- Create another secret named `SONAR_HOST_URL` with our VM's address (e.g., `http://4.228.228.218:9000`)  

### Creating the GitHub Actions Workflow

The final piece is the automation workflow:

- In our repository, create `.github/workflows/sonarqube.yml`  
- Add the following configuration:  

```yml
name: Build, Test and SonarQube Analysis

on:
  push:
    branches: [ main ]  # Trigger on pushes to main
  pull_request:
    branches: [ main ]  # Trigger on PRs to main

jobs:
  build:
    runs-on: ubuntu-latest  # Use latest Ubuntu runner
    
    services:
      # Configure PostgreSQL container for tests
      postgres:
        image: postgres:latest  # Official Postgres image
        env:
          POSTGRES_DB: clinic_test  # Test database name
          POSTGRES_USER: test_user  # Test DB username
          POSTGRES_PASSWORD: test_password  # Test DB password
        ports:
          - 5436:5432  # Map host 5436 to container 5432
        options: >-
          --health-cmd pg_isready  # Health check command
          --health-interval 10s    # Check every 10s
          --health-timeout 5s      # Timeout after 5s
          --health-retries 5       # Retry 5 times before failing

    steps:
    # Checkout repository code
    - name: Checkout code
      uses: actions/checkout@v4  # Latest checkout action

    # Set up Java environment
    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: 17  # Use JDK 17
        distribution: 'temurin'  # Eclipse Temurin distribution

    # Wait for DB to be ready
    - name: Wait for PostgreSQL to be ready
      run: sleep 10  # 10s buffer for DB initialization

    # Build and test
    - name: Build and run tests
      env:
        SPRING_DATASOURCE_URL: jdbc:postgresql://localhost:5436/clinic_test  # Test DB URL
        SPRING_DATASOURCE_USERNAME: test_user  # DB username
        SPRING_DATASOURCE_PASSWORD: test_password  # DB password
      run: |
        mvn -B verify  # Run Maven build and tests

    # SonarQube analysis
    - name: SonarQube Scan
      env:
        SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}  # Auth token from secrets
        SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}  # SonarQube server URL
      run: |
        # Run SonarQube analysis with explicit plugin version
        mvn org.sonarsource.scanner.maven:sonar-maven-plugin:3.11.0.3922:sonar -Dsonar.projectKey=Github-Test

    # Upload test results (optional)
    - name: Upload test results
      if: always()  # Run even if previous steps fail
      uses: actions/upload-artifact@v4  # Latest artifact upload
      with:
        name: test-results  # Artifact name
        path: target/surefire-reports  # Test report directory
``` 

## 4. Conclusions

By successfully integrating SonarQube with GitHub Actions on an Azure VM, we have established a robust and automated pipeline for continuous code quality analysis. This setup enhances our development workflow by:

- Automatically analyzing code on every push and pull request  
- Providing clear insights into code quality, bugs, and vulnerabilities  
- Enforcing coding standards through configurable quality gates  
- Promoting early detection of issues to reduce technical debt 