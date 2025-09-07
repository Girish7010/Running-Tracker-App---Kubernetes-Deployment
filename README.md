# 🏃‍♂️ Running Tracker App - Kubernetes Deployment

A modern, responsive running tracker application deployed on Kubernetes with automated setup and deployment scripts.

![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Node.js](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)
![Express.js](https://img.shields.io/badge/express.js-%23404d59.svg?style=for-the-badge&logo=express&logoColor=%2361DAFB)

## 📖 Overview

This project demonstrates a complete containerized application deployment on Kubernetes, featuring:

- **Modern Web Application**: Beautiful, responsive running tracker with real-time pace calculations
- **Microservices Architecture**: Node.js backend with REST API and static frontend
- **Kubernetes Orchestration**: Complete K8s deployment with health checks, scaling, and monitoring
- **Automated DevOps**: One-command setup and deployment script
- **Production-Ready**: Includes health checks, resource limits, and monitoring

## ✨ Features

### 🎯 Application Features
- ✅ Track running sessions (date, distance, duration, location)
- ✅ Automatic pace calculation (min/km)
- ✅ Responsive, mobile-friendly interface
- ✅ Real-time data validation
- ✅ Modern glassmorphism UI design
- ✅ Progressive animations and interactions

### 🚀 DevOps Features
- ✅ Automated Kubernetes setup (minikube, kubectl, Docker)
- ✅ One-command deployment
- ✅ Health checks (liveness & readiness probes)
- ✅ Horizontal scaling (2 replicas)
- ✅ Resource management (CPU/Memory limits)
- ✅ Service discovery and load balancing
- ✅ Complete cleanup automation

## 🛠️ Tech Stack

| Component | Technology |
|-----------|------------|
| **Frontend** | HTML5, CSS3, Vanilla JavaScript |
| **Backend** | Node.js, Express.js |
| **Container** | Docker |
| **Orchestration** | Kubernetes (minikube) |
| **Storage** | In-memory (easily extensible to databases) |
| **Networking** | NodePort Service |
| **Monitoring** | Kubernetes health checks |

## 📂 Project Structure

```
K8S-Project/
├── 📄 README.md              # This file
├── 🖥️ server.js              # Node.js backend API
├── 📱 index.html             # Frontend application
├── 📦 package.json           # Node.js dependencies
├── 🐳 Dockerfile             # Container configuration
├── ☸️ k8s-deployment.yaml    # Kubernetes manifests
└── 🚀 deploy.sh              # Automated deployment script
```

## 🚀 Quick Start

### Prerequisites
- Linux (Ubuntu/Debian preferred)
- Internet connection for package downloads
- Sudo privileges for initial setup

### 🎯 One-Command Deployment

```bash
# Clone or download the project files
git clone <your-repo-url>
cd K8S-Project

# Make the deployment script executable
chmod +x deploy.sh

# Deploy everything (installs K8s tools if needed)
./deploy.sh
```

### 📱 Access Your App

After successful deployment:

```bash
# Option 1: Get the service URL
minikube service running-app-service --url

# Option 2: Port forward to localhost
kubectl port-forward service/running-app-service 8080:80
# Then visit: http://localhost:8080

# Option 3: Use minikube IP
minikube ip  # Get the IP
# Visit: http://[MINIKUBE-IP]:30080
```

## 📋 Detailed Setup

### Manual Installation (if automated script fails)

#### 1. Install Prerequisites
```bash
# Update system
sudo apt update

# Install Docker
sudo apt install -y docker.io
sudo usermod -aG docker $USER
newgrp docker

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

#### 2. Start Kubernetes Cluster
```bash
# Start minikube
minikube start --driver=docker --memory=4096 --cpus=2

# Verify cluster
kubectl cluster-info
kubectl get nodes
```

#### 3. Deploy Application
```bash
# Build Docker image
docker build -t running-app:latest .

# Load image into minikube
minikube image load running-app:latest

# Deploy to Kubernetes
kubectl apply -f k8s-deployment.yaml

# Check deployment status
kubectl get pods,services
```

## 🎛️ Management Commands

### 📊 Monitoring
```bash
# View application logs
kubectl logs -f deployment/running-app

# Check pod status
kubectl get pods -l app=running-app

# View service details
kubectl get services

# Open Kubernetes dashboard
minikube dashboard

# Check resource usage
kubectl top pods
```

### 🔧 Scaling
```bash
# Scale up replicas
kubectl scale deployment running-app --replicas=5

# Scale down
kubectl scale deployment running-app --replicas=1

# Check scaling status
kubectl get deployments
```

### 🧹 Cleanup

```bash
# Remove application only
./deploy.sh clean

# Complete cleanup (removes K8s cluster)
./deploy.sh complete-clean

# Manual cleanup
kubectl delete -f k8s-deployment.yaml
minikube delete
```

## 🏗️ Architecture

### Application Architecture
```
┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │
│   (HTML/CSS/JS) │───▶│   (Node.js)     │
│   Port: 3000    │    │   Express API   │
└─────────────────┘    └─────────────────┘
```

### Kubernetes Architecture
```
┌─────────────────────────────────────┐
│             Kubernetes              │
│  ┌─────────────┐  ┌─────────────┐   │
│  │   Pod 1     │  │   Pod 2     │   │
│  │ running-app │  │ running-app │   │
│  └─────────────┘  └─────────────┘   │
│         │                │         │
│  ┌─────────────────────────────┐    │
│  │      NodePort Service       │    │
│  │       Port: 30080          │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

## 🔧 Configuration

### Environment Variables
| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `3000` | Application port |
| `NODE_ENV` | `production` | Node.js environment |

### Resource Limits
| Resource | Request | Limit |
|----------|---------|-------|
| **Memory** | 64Mi | 128Mi |
| **CPU** | 50m | 100m |

### Health Checks
- **Liveness Probe**: `/health` endpoint every 10s
- **Readiness Probe**: `/health` endpoint every 5s
- **Startup Time**: 30s initial delay

## 📋 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/` | Frontend application |
| `GET` | `/api/runs` | Get all runs |
| `POST` | `/api/runs` | Create new run |
| `DELETE` | `/api/runs/:id` | Delete run by ID |
| `GET` | `/health` | Health check |

### API Usage Examples

```bash
# Get all runs
curl http://localhost:30080/api/runs

# Create a new run
curl -X POST http://localhost:30080/api/runs \
  -H "Content-Type: application/json" \
  -d '{"date":"2024-01-15","distance":5.2,"duration":28,"location":"Central Park"}'

# Health check
curl http://localhost:30080/health
```

## 🔍 Troubleshooting

### Common Issues

#### 🚫 "This site can't be reached"
```bash
# Get the correct service URL
minikube service running-app-service --url

# Or use port forwarding
kubectl port-forward service/running-app-service 8080:80
```

#### 🐳 Docker Permission Denied
```bash
# Fix Docker permissions
sudo usermod -aG docker $USER
newgrp docker

# Or temporarily fix socket permissions
sudo chmod 666 /var/run/docker.sock
```

#### ☸️ Minikube Won't Start
```bash
# Delete and recreate cluster
minikube delete
minikube start --driver=docker

# Check system resources
free -h  # Check memory
df -h    # Check disk space
```

#### 🔄 Pods Not Starting
```bash
# Check pod logs
kubectl logs deployment/running-app

# Describe pod for events
kubectl describe pods -l app=running-app

# Check node resources
kubectl describe nodes
```

#### 📦 Image Pull Issues
```bash
# Rebuild and reload image
docker build -t running-app:latest .
minikube image load running-app:latest

# Verify image in minikube
minikube ssh docker images
```

### Debug Commands

```bash
# Full system status
kubectl get all

# Detailed pod information
kubectl describe pod <pod-name>

# Enter pod shell
kubectl exec -it <pod-name> -- /bin/sh

# View cluster events
kubectl get events --sort-by='.lastTimestamp'

# Check minikube status
minikube status
```

## 🚀 Advanced Usage

### Custom Deployment Options

```bash
# Deploy with custom settings
./deploy.sh                    # Full deployment
./deploy.sh setup-only         # Setup K8s tools only
./deploy.sh install-tools      # Install tools with sudo
./deploy.sh clean             # Remove app only
./deploy.sh complete-clean    # Full cleanup
```

### Extending the Application

#### Add Database (MongoDB Example)
```yaml
# Add to k8s-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mongodb
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mongodb
  template:
    metadata:
      labels:
        app: mongodb
    spec:
      containers:
      - name: mongodb
        image: mongo:latest
        ports:
        - containerPort: 27017
```

#### Enable Ingress
```bash
# Enable ingress addon
minikube addons enable ingress

# Create ingress resource
kubectl apply -f ingress.yaml