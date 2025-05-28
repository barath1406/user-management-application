# Helm Chart for User Portal

This folder contains the Helm chart for deploying the **User Portal** Flask application on Kubernetes. The chart includes all necessary Kubernetes resources such as Deployment, Service, Ingress, and ServiceAccount.

## Chart Information

- **Name:** user-portal  
- **Description:** A Helm chart for deploying the Flask User Management Application  
- **Version:** 0.0.1  
- **App Version:** 1.0  

## Installation

### Prerequisites

Before deploying the chart, ensure you have the following installed and configured:

- [kubectl](https://kubernetes.io/docs/tasks/tools/)  
- [Helm 3](https://helm.sh/docs/intro/install/)  
- Access to a Kubernetes cluster (version 1.16+)  
- AWS CLI configured with appropriate permissions (if using AWS EKS and IAM roles)  

### Deployment Steps

> The application deployment is done via Helm. The commands below are provided for deployment and to validate Kubernetes resources or troubleshoot pods if needed.

### Install NGINX Ingress Controller

Before deploying the chart, ensure the NGINX Ingress Controller is installed in your Kubernetes cluster. Use the following commands to install it:

```bash
aws eks update-kubeconfig --name {Cluster_Name} --region us-east-1
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=NodePort \
  --set controller.service.nodePorts.http=30080 \
  --set controller.service.nodePorts.https=30443
```

#### Namespace Creation

This allows you to customize the deployment in a custom namespace.

1. *(Optional)* Create a namespace if you want to deploy in a specific namespace:

```bash
kubectl create namespace <namespace>
```

#### Helm Dry Run

Before applying changes, you can perform a dry run to preview the Kubernetes resources that Helm will create or modify without actually deploying them. This is useful for validation and troubleshooting.

Use the following command to perform a dry run:

```bash
helm upgrade --install --dry-run --debug barath-user-portal . -n <namespace>
```

This command will simulate the deployment, showing the rendered Kubernetes manifests and any potential errors, without making any changes to your cluster.

#### Environment Values Usage

The deployment uses environment-specific values files located in the `env_values/` directory. These files contain configuration overrides for different environments (e.g., development, staging, production).

To deploy using a specific environment values file, use the `-f` flag with Helm:

```bash
helm upgrade --install -f env_values/development_values.yaml -f values.yaml barath-user-portal . -n <namespace>
```
## Configuration

The following table lists the configurable parameters of the chart and their default values (defined in `values.yaml` and environment values files):

| Parameter                         | Description                                                  | Default                                   |
|----------------------------------|--------------------------------------------------------------|-------------------------------------------|
| replicaCount                     | Number of pod replicas to deploy                             | 2                                         |
| image.repository                | Docker image repository                                       | barath1406/user-portal                     |
| image.tag                       | Docker image tag/version                                      | "0.0.1"                                   |
| image.pullPolicy                | Image pull policy                                            | IfNotPresent                              |
| nameOverride                   | Override the chart name                                       | ""                                        |
| fullnameOverride               | Override the full chart name                                  | ""                                        |
| service.type                   | Kubernetes service type (e.g., ClusterIP, NodePort, LoadBalancer) | NodePort                                  |
| service.port                   | Service port exposed                                         | 443                                       |
| service.targetPort             | Target port on the pod                                        | 5000                                      |
| service.nodePort               | Node port for NodePort service                                | 30081                                     |
| service.protocol               | Protocol used by the service                                  | TCP                                       |
| service.name                   | Name of the service                                          | http                                      |
| resources.limits.cpu           | CPU limit for the container                                   | 500m                                      |
| resources.limits.memory        | Memory limit for the container                                | 512Mi                                     |
| resources.requests.cpu         | CPU request for the container                                 | 200m                                      |
| resources.requests.memory      | Memory request for the container                              | 256Mi                                     |
| livenessProbe.httpGet.path     | HTTP path for liveness probe                                  | /                                         |
| livenessProbe.httpGet.port     | HTTP port for liveness probe                                  | 5000                                      |
| livenessProbe.initialDelaySeconds | Initial delay before liveness probe starts                  | 30                                        |
| livenessProbe.periodSeconds    | Period between liveness probe checks                          | 10                                        |
| readinessProbe.httpGet.path    | HTTP path for readiness probe                                 | /                                         |
| readinessProbe.httpGet.port    | HTTP port for readiness probe                                 | 5000                                      |
| readinessProbe.initialDelaySeconds | Initial delay before readiness probe starts                 | 5                                         |
| readinessProbe.periodSeconds   | Period between readiness probe checks                         | 5                                         |
| aws.region                    | AWS region for deployment                                     | us-east-1                              |
| serviceAccount.create          | Create a Kubernetes service account                           | true                                      |
| serviceAccount.name            | Name of the service account                                   | barath-user-portal-sa                      |
| serviceAccount.iamRole         | IAM role ARN associated with the service account             | arn:aws:iam::1234567890:role/barath-user-portal-role |
| podAnnotations                | Annotations to add to pods                                    | {}                                        |
| ingress.enabled               | Enable or disable ingress                                     | true                                      |
| ingress.ingressClassName      | Ingress class name                                            | nginx                                     |
| ingress.serviceName           | Service name for ingress                                      | barath-user-portal-service                 |
| ingress.servicePort           | Service port for ingress                                      | 443                                       |
| ingress.host                  | Hostname for ingress                                         | barath.network               |
| ingress.path                  | Path for ingress routing                                     | /(.*)                                     |
| ingress.pathType              | Path type for ingress routing                                | ImplementationSpecific                     |
| ingress.namespace             | Namespace for ingress resources                               | barath                                    |
| ingress.annotations           | Annotations for ingress resources                            | nginx.ingress.kubernetes.io/ssl-redirect: "true", nginx.ingress.kubernetes.io/use-regex: "true", nginx.ingress.kubernetes.io/rewrite-target: /$1 |

## Useful kubectl Commands for Troubleshooting

- List all resources in the current namespace:

```bash
kubectl get all
```

- List all pods:

```bash
kubectl get pods
```

- Describe a specific pod (replace `<pod-name>` with the actual pod name):

```bash
kubectl describe pod <pod-name>
```

- View logs of a specific pod (replace `<pod-name>` with the actual pod name):

```bash
kubectl logs <pod-name>
```

- List all services:

```bash
kubectl get services
```

- List all deployments:

```bash
kubectl get deployments
```

- List all ingress resources:

```bash
kubectl get ingress
```

- List all service accounts:

```bash
kubectl get serviceaccounts
```

- Describe a specific service account (replace `<serviceaccount-name>` with the actual name):

```bash
kubectl describe serviceaccount <serviceaccount-name>
```

> To target a specific namespace, append `-n <namespace>` to the above commands.

## Kubernetes Resources Created

- **Deployment:** Runs the Flask User Portal application with the specified number of replicas, container image, resource limits, and probes.  
- **Service:** Exposes the application internally with the specified service type and ports.  
- **Ingress:** Configures an ALB ingress with HTTPS and routing rules.  
- **ServiceAccount:** Creates a service account with an associated IAM role for AWS EKS.  

## Usage Notes

- Customize the `values.yaml` file to adjust the deployment to your environment.  
- Ensure the IAM role ARN specified in `serviceAccount.iamRole` has the necessary permissions.  
- The ingress is configured for AWS ALB with HTTPS; update the certificate ARN and other annotations as needed.  
- The application listens on port 5000 internally and is exposed on port 443 externally.  