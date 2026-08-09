# Jenkins Plugins

## 1. Overview

Jenkins plugins extend the core Jenkins platform with capabilities for source control, pipeline execution, credentials management, Docker integration, AWS integration, and security.

The plugin set for this project is intentionally limited to capabilities required by the CI/CD architecture.

The goal is to follow the principle of **minimum required functionality** rather than installing unnecessary plugins.

---

## 2. Core Plugins

The following plugin capabilities are required for the Enterprise DevOps Platform.

| Plugin              | Purpose                                                 |
| ------------------- | ------------------------------------------------------- |
| Pipeline            | Defines and executes CI/CD pipelines using Jenkinsfiles |
| Git                 | Provides Git source-control integration                 |
| GitHub              | Integrates Jenkins with GitHub repositories             |
| Credentials Binding | Securely injects credentials into pipeline steps        |
| SSH Build Agents    | Supports Jenkins agent connectivity                     |
| Pipeline Stage View | Provides visibility into pipeline stages                |

---

## 3. Container and Build Plugins

Docker is used as the container build and packaging platform.

| Plugin          | Purpose                                            |
| --------------- | -------------------------------------------------- |
| Docker Pipeline | Provides Docker operations from Jenkins pipelines  |
| Docker          | Provides Docker-related Jenkins integration        |
| Docker Commons  | Shared Docker functionality used by Docker plugins |

The Jenkins pipeline will use Docker to build application images and prepare them for deployment.

---

## 4. AWS Integration

AWS resources are provisioned and managed through Terraform.

AWS credentials should not be hard-coded into Jenkinsfiles.

Where Jenkins requires AWS authentication, credentials should be stored in Jenkins Credentials or, preferably, provided through an AWS IAM role attached to the Jenkins infrastructure.

The target architecture is:

```text
Jenkins
   |
   | IAM Role
   v
AWS APIs
```

This avoids storing long-lived AWS access keys directly in pipeline code.

---

## 5. Security and Credentials

Jenkins credentials are managed through the Jenkins Credentials subsystem.

Credentials must not be stored in:

* Jenkinsfiles
* Git repositories
* Terraform source code
* Dockerfiles
* Shell scripts
* Application configuration committed to Git

Sensitive values should be injected only at runtime.

Example:

```groovy
withCredentials([
    string(
        credentialsId: 'example-secret',
        variable: 'SECRET_VALUE'
    )
]) {
    sh 'some-command'
}
```

The actual secret value should never be written directly into the Jenkinsfile.

---

## 6. Pipeline Architecture

The plugins support the following pipeline:

```text
GitHub
   |
   | Webhook
   v
Jenkins
   |
   +-- Checkout
   |
   +-- Build
   |
   +-- Test
   |
   +-- Trivy Scan
   |
   +-- Docker Build
   |
   +-- Docker Image Scan
   |
   +-- Docker Push
   |
   +-- Terraform
   |
   +-- AWS Deployment
```

---

## 7. Plugin Management

Plugins should be installed from:

```text
Manage Jenkins
    |
    └── Plugins
```

The Jenkins plugin manager is used to install approved plugins and apply updates.

Plugins should be reviewed periodically for:

* Security vulnerabilities
* Compatibility
* Maintenance status
* Dependency changes
* Available updates

Unused plugins should be removed to reduce the Jenkins attack surface.

---

## 8. Plugin Security

Jenkins plugins execute code within the Jenkins environment and therefore represent part of the CI/CD platform's trusted computing base.

Plugin installation should follow these principles:

1. Install only required plugins.
2. Prefer maintained plugins.
3. Keep plugins updated.
4. Review security advisories.
5. Remove unused plugins.
6. Avoid plugins that duplicate existing functionality.
7. Test plugin upgrades before production rollout.

---

## 9. Current Project Plugin Strategy

The development Jenkins server will initially use the minimum plugin set required to implement the pipeline.

Additional plugins will only be introduced when a specific pipeline or operational requirement exists.

This prevents unnecessary platform complexity and keeps the CI/CD environment easier to maintain.

---

## 10. Validation

After installing the required plugins, verify them through:

```text
Manage Jenkins
    |
    └── Plugins
        └── Installed plugins
```

The plugin versions should be recorded when the Jenkins environment is considered production-ready.

---

## 11. Future Improvements

As the platform evolves, additional capabilities may be introduced for:

* Pipeline visualization
* Code quality analysis
* Artifact management
* Kubernetes-based Jenkins agents
* Automated deployment approvals
* Notifications
* Distributed build execution
* Centralized secrets management
* Audit and compliance reporting
