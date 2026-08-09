# Jenkins Installation

## 1. Overview

Jenkins is deployed on an AWS EC2 instance running Ubuntu 24.04 LTS.

Jenkins is used as the CI/CD orchestration server for the Enterprise DevOps Platform. The server will execute application builds, automated tests, security scanning, Docker image builds, image publishing, and deployment workflows.

### Jenkins Server

| Component              | Configuration    |
| ---------------------- | ---------------- |
| Cloud Provider         | AWS              |
| Operating System       | Ubuntu 24.04 LTS |
| Instance Type          | t3.micro         |
| Jenkins Port           | 8080             |
| Java Runtime           | OpenJDK 21       |
| VPC                    | dev-vpc          |
| Subnet                 | dev-public-1     |
| Jenkins Security Group | jenkins-sg       |

---

## 2. Network Architecture

The Jenkins EC2 instance is deployed into the public subnet of the development VPC.

```text
AWS
└── dev-vpc
    ├── dev-public-1
    │   └── Jenkins EC2
    │       └── Jenkins :8080
    │
    ├── dev-public-2
    │
    ├── dev-private-1
    │
    └── dev-private-2
```

The public subnet uses an Internet Gateway route to provide external connectivity to the Jenkins server.

---

## 3. Security Group

The Jenkins EC2 instance uses the `jenkins-sg` security group.

Required inbound ports:

| Protocol | Port | Purpose               |
| -------- | ---: | --------------------- |
| TCP      |   22 | SSH administration    |
| TCP      |   80 | HTTP                  |
| TCP      |  443 | HTTPS                 |
| TCP      | 8080 | Jenkins web interface |

SSH should preferably be restricted to a trusted administrative IP range in a production environment.

The Jenkins administration interface should also be protected behind a controlled network path in production rather than being exposed directly to the public internet.

---

## 4. Java Installation

Jenkins requires a supported Java runtime.

OpenJDK 21 was installed:

```bash
sudo apt update
sudo apt install -y fontconfig openjdk-21-jre
```

Verify the installation:

```bash
java -version
```

Expected output should identify Java 21.

---

## 5. Jenkins Repository Configuration

The Jenkins Debian repository was configured using the official Jenkins signing key.

```bash
sudo mkdir -p /usr/share/keyrings

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
```

The Jenkins repository was then added:

```bash
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
```

The package index was updated:

```bash
sudo apt update
```

The Jenkins repository was successfully detected by APT.

---

## 6. Jenkins Installation

Jenkins was installed using APT:

```bash
sudo apt install -y jenkins
```

The Jenkins service was enabled to start automatically after system boot:

```bash
sudo systemctl enable jenkins
```

Jenkins was started:

```bash
sudo systemctl start jenkins
```

---

## 7. Jenkins Service Verification

The Jenkins service was verified using:

```bash
sudo systemctl status jenkins --no-pager
```

Jenkins was confirmed to be running.

The Jenkins listening port was verified:

```bash
sudo ss -lntp | grep 8080
```

The server returned:

```text
LISTEN 0 50 *:8080 *:* users:(("java",pid=...,fd=9))
```

This confirms that Jenkins is listening on TCP port 8080 on the EC2 server.

---

## 8. Initial Jenkins Configuration

The initial administrator password was retrieved using:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

The Jenkins web interface was accessed through:

```text
http://<JENKINS_PUBLIC_IP>:8080
```

The Jenkins setup wizard was then completed through the web interface.

---

## 9. Jenkins Data Directory

The Jenkins home directory is:

```text
/var/lib/jenkins
```

This directory contains Jenkins configuration, jobs, plugins, credentials metadata, and other Jenkins runtime data.

The Jenkins service runs under the dedicated Linux user:

```text
jenkins
```

---

## 10. Installed DevOps Tooling

The Jenkins server is being configured with the tools required for the CI/CD pipeline.

| Tool      | Purpose                             |
| --------- | ----------------------------------- |
| Git       | Source code management              |
| Java 21   | Jenkins runtime                     |
| Terraform | Infrastructure as Code              |
| Trivy     | Vulnerability and security scanning |
| Docker    | Container image build and execution |

Tool access is verified using the Jenkins service account where applicable.

For example:

```bash
sudo -u jenkins terraform version
```

and:

```bash
sudo -u jenkins trivy --version
```

Trivy was verified successfully for the Jenkins service account.

---

## 11. Installation Validation

The Jenkins installation is considered successful when all of the following are true:

```bash
systemctl is-active jenkins
```

```bash
java -version
```

```bash
terraform version
```

```bash
sudo -u jenkins trivy --version
```

```bash
sudo ss -lntp | grep 8080
```

These checks confirm that the Jenkins service and required CI/CD tooling are available.

---

## 12. Operational Considerations

The Jenkins server is currently part of the development environment.

For a production implementation, additional controls should be introduced, including:

* Restricting SSH access.
* Restricting Jenkins UI access.
* Using HTTPS with a valid TLS certificate.
* Implementing centralized secrets management.
* Backing up Jenkins configuration.
* Monitoring Jenkins health and resource utilization.
* Applying OS and Jenkins security updates.
* Using dedicated Jenkins agents for pipeline workloads.
* Implementing least-privilege IAM permissions.
* Avoiding long-lived AWS credentials on the Jenkins host.

---

## 13. Current Status

Jenkins is installed and operational on AWS EC2.

The server is ready for CI/CD pipeline configuration and integration with GitHub, Docker, Terraform, Trivy, and AWS.
