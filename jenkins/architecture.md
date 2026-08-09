# Jenkins CI/CD Architecture

## 1. Purpose

Jenkins is the CI/CD orchestration layer for the Enterprise DevOps Platform.

The platform is designed to automate the software delivery lifecycle from source-code commit through build, security validation, containerization, and AWS deployment.

The architecture separates infrastructure provisioning from application delivery:

* **Terraform** manages AWS infrastructure.
* **Jenkins** orchestrates CI/CD.
* **GitHub** manages source code.
* **Trivy** performs security scanning.
* **Docker** packages applications into containers.
* **AWS** provides the cloud infrastructure and deployment environment.

---

## 2. High-Level Architecture

```text
                         Developer
                             |
                             | git push
                             v
                     +----------------+
                     |    GitHub      |
                     | Repository     |
                     +-------+--------+
                             |
                             | Webhook
                             v
                  +----------------------+
                  |       Jenkins        |
                  |      CI/CD           |
                  +----------+-----------+
                             |
             +---------------+----------------+
             |               |                |
             v               v                v
          Build           Testing           Trivy
                                             Scan
             |               |                |
             +---------------+----------------+
                             |
                             v
                     +---------------+
                     |    Docker     |
                     |     Build     |
                     +-------+-------+
                             |
                             v
                     Container Registry
                             |
                             v
                         AWS Deploy
```

---

## 3. AWS Infrastructure

The Jenkins server runs on an AWS EC2 instance inside the development VPC.

```text
AWS
|
+-- VPC: dev-vpc
    |
    +-- Public Subnet
    |   |
    |   +-- Jenkins EC2
    |       |
    |       +-- Jenkins
    |       +-- Java 21
    |       +-- Terraform
    |       +-- Trivy
    |       +-- Docker
    |
    +-- Private Subnet
        |
        +-- Application / Data workloads
```

The VPC is provisioned using Terraform.

The development VPC uses:

```text
CIDR: 10.0.0.0/16
```

The architecture contains separate public and private subnet tiers.

---

## 4. Jenkins Server

Jenkins runs on an Ubuntu 24.04 LTS EC2 instance.

The Jenkins server provides the execution environment for CI/CD pipelines.

Installed tooling includes:

| Tool      | Purpose                   |
| --------- | ------------------------- |
| Java 21   | Jenkins runtime           |
| Git       | Source-code checkout      |
| Terraform | Infrastructure automation |
| Trivy     | Security scanning         |
| Docker    | Container builds          |
| Jenkins   | CI/CD orchestration       |

The Jenkins service runs under the dedicated Linux account:

```text
jenkins
```

This prevents pipelines from executing directly as the root user.

---

## 5. Source Control

GitHub is the source-code management platform.

Developers push application and infrastructure changes to GitHub.

The target workflow is:

```text
Developer
    |
    v
Git commit
    |
    v
GitHub
    |
    v
Jenkins Webhook
```

Jenkins then retrieves the repository and executes the defined pipeline.

Pipeline configuration will be stored as code using a `Jenkinsfile`.

---

## 6. CI Pipeline

The continuous integration process will follow these stages:

```text
Checkout
   |
   v
Build
   |
   v
Unit Tests
   |
   v
Static / Security Checks
   |
   v
Trivy Filesystem Scan
   |
   v
Docker Build
   |
   v
Trivy Image Scan
```

A failed stage prevents the pipeline from continuing.

This provides an automated quality gate before an artifact is promoted.

---

## 7. Containerization

Docker is used to package the application and its runtime dependencies into immutable container images.

The expected workflow is:

```text
Source Code
    |
    v
Dockerfile
    |
    v
Docker Build
    |
    v
Container Image
    |
    v
Trivy Image Scan
    |
    v
Container Registry
```

Container images will be versioned using immutable tags rather than relying exclusively on `latest`.

---

## 8. Security Scanning

Trivy is integrated into the CI pipeline.

Trivy will be used to identify:

* OS package vulnerabilities
* Application dependency vulnerabilities
* Container image vulnerabilities
* Infrastructure configuration issues where applicable

The security scanning stage acts as a CI quality gate.

A future implementation will define severity thresholds that determine whether a build is allowed to proceed.

---

## 9. Infrastructure as Code

Terraform is responsible for provisioning AWS infrastructure.

The architecture separates Terraform execution from application deployment.

```text
Terraform
    |
    +-- VPC
    +-- Subnets
    +-- Route Tables
    +-- Internet Gateway
    +-- NAT Gateway
    +-- Security Groups
    +-- EC2
    +-- Other AWS Resources
```

Terraform state is stored remotely in Amazon S3.

Infrastructure changes are reviewed through version control before being applied.

---

## 10. AWS Authentication

Jenkins should use AWS IAM rather than long-lived access keys wherever possible.

The preferred architecture is:

```text
Jenkins EC2
     |
     | IAM Role
     v
AWS APIs
```

This provides temporary credentials through the EC2 instance metadata service.

The IAM role should follow least-privilege principles.

Jenkins should only receive permissions required for the pipeline operations it performs.

---

## 11. Secrets Management

Secrets must not be committed to GitHub.

The following should never appear in source control:

```text
AWS access keys
AWS secret keys
Docker registry passwords
Database passwords
API keys
Private keys
Jenkins credentials
```

Jenkins Credentials or an external secrets-management solution should be used for sensitive values.

For AWS authentication, IAM roles are preferred over static credentials.

---

## 12. CI/CD Separation

The platform separates continuous integration from deployment responsibilities.

### Continuous Integration

Jenkins validates the application:

```text
Checkout
   |
Build
   |
Test
   |
Security Scan
   |
Docker Build
   |
Image Scan
```

### Continuous Delivery

After successful validation:

```text
Approved Artifact
       |
       v
Container Registry
       |
       v
AWS Deployment
```

This prevents unvalidated application artifacts from reaching the deployment environment.

---

## 13. Environment Strategy

The platform will eventually support multiple environments:

```text
Development
     |
     v
Staging
     |
     v
Production
```

Terraform variables and separate state management will be used to prevent environments from sharing mutable infrastructure state.

Production deployments should include additional controls such as:

* Manual approval
* Restricted IAM permissions
* Deployment windows where required
* Automated rollback
* Monitoring validation
* Audit logging

---

## 14. Jenkins Pipeline as Code

The CI/CD process will be defined in a `Jenkinsfile` stored with the application source code.

Example structure:

```groovy
pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                // Application build
            }
        }

        stage('Test') {
            steps {
                // Automated tests
            }
        }

        stage('Security Scan') {
            steps {
                // Trivy scan
            }
        }

        stage('Docker Build') {
            steps {
                // Docker image build
            }
        }

        stage('Image Scan') {
            steps {
                // Trivy image scan
            }
        }

        stage('Deploy') {
            steps {
                // AWS deployment
            }
        }
    }
}
```

The final Jenkinsfile will be implemented after the required build and deployment components are configured.

---

## 15. Reliability Considerations

Jenkins is a critical component of the delivery platform.

The architecture therefore requires:

* Automated service startup
* Jenkins configuration backups
* Infrastructure as Code
* Monitoring
* Centralized logging where appropriate
* Restricted administrative access
* Plugin lifecycle management
* Disaster recovery procedures

The Jenkins server itself should not become a single point of failure for production deployments.

A future production architecture may use dedicated Jenkins controllers and ephemeral agents.

---

## 16. Security Boundaries

The platform contains several security boundaries:

```text
Internet
   |
   v
AWS Security Group
   |
   v
Jenkins EC2
   |
   +---- IAM Role ----> AWS APIs
   |
   +---- GitHub ------> Source Code
   |
   +---- Registry ----> Container Images
```

Security controls should be applied at each boundary.

---

## 17. Architectural Decisions

### Jenkins on EC2

Jenkins is deployed on EC2 to provide direct control over the CI/CD execution environment and to support the hands-on portfolio objective.

### Terraform for Infrastructure

Terraform provides repeatable and version-controlled infrastructure provisioning.

### GitHub for Source Control

GitHub provides version control, collaboration, pull requests, and integration with Jenkins.

### Docker for Packaging

Docker provides consistent application packaging across development and deployment environments.

### Trivy for Security

Trivy provides automated vulnerability scanning within the CI pipeline.

### IAM Roles for AWS Access

IAM roles eliminate the need to store long-lived AWS access keys on the Jenkins server.

### Pipeline as Code

The Jenkinsfile keeps CI/CD logic version-controlled alongside the application.

---

## 18. Target State

The completed platform will provide:

```text
Developer
    |
    v
GitHub
    |
    | Webhook
    v
Jenkins
    |
    +-- Build
    +-- Test
    +-- Trivy Scan
    +-- Docker Build
    +-- Image Scan
    |
    v
Container Registry
    |
    v
AWS
    |
    +-- Infrastructure managed by Terraform
    |
    +-- Application deployment
    |
    +-- Monitoring and operational controls
```

The architecture is designed to demonstrate practical DevOps engineering principles including automation, Infrastructure as Code, security scanning, immutable artifacts, least-privilege access, pipeline-as-code, and repeatable deployments.
