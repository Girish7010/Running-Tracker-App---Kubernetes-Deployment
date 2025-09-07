#!/bin/bash

# Combined Kubernetes Setup and Running App Deployment Script
# This will install minikube/kubectl if needed, then deploy the app

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

echo "🏃‍♂️ Running Tracker App - Complete Setup & Deployment"
echo "======================================================"

# Function to setup Kubernetes
setup_kubernetes() {
    echo "🐧 Setting up Kubernetes on Linux..."
    echo "===================================="

    # Update system
    print_status "Updating system packages..."
    sudo apt update

    # Install Docker if not present
    if ! command -v docker &> /dev/null; then
        print_status "Installing Docker..."
        
        # Install dependencies
        sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
        
        # Add Docker GPG key
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        
        # Add Docker repository
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        # Install Docker
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io
        
        # Add user to docker group
        sudo usermod -aG docker $USER
        
        print_success "Docker installed! Applying group changes..."
        newgrp docker
    else
        print_success "Docker is already installed"
    fi

    # Ensure user is in docker group
    if ! groups $USER | grep -q docker; then
        print_warning "Adding user to docker group..."
        sudo usermod -aG docker $USER
        print_warning "Applying group changes..."
        newgrp docker
    fi

    # Install kubectl
    if ! command -v kubectl &> /dev/null; then
        print_status "Installing kubectl..."
        
        # Download kubectl
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        
        # Make it executable and move to PATH
        chmod +x kubectl
        sudo mv kubectl /usr/local/bin/
        
        print_success "kubectl installed!"
    else
        print_success "kubectl is already installed"
    fi

    # Install minikube
    if ! command -v minikube &> /dev/null; then
        print_status "Installing minikube..."
        
        # Download and install minikube
        curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
        sudo install minikube-linux-amd64 /usr/local/bin/minikube
        rm minikube-linux-amd64
        
        print_success "minikube installed!"
    else
        print_success "minikube is already installed"
    fi

    # Start Docker service
    print_status "Starting Docker service..."
    sudo systemctl start docker
    sudo systemctl enable docker

    # Verify Docker works
    print_status "Testing Docker..."
    if docker ps &> /dev/null; then
        print_success "Docker is working!"
    else
        print_error "Docker is not working. Trying to fix permissions..."
        sudo chmod 666 /var/run/docker.sock
        if docker ps &> /dev/null; then
            print_success "Docker is now working!"
        else
            print_error "Docker still not working. You may need to restart your session"
            exit 1
        fi
    fi

    print_success "✅ All tools installed successfully!"
}

# Function to start Kubernetes cluster
start_kubernetes_cluster() {
    print_status "Starting Kubernetes cluster..."
    
    # Check if minikube is already running
    if minikube status &> /dev/null; then
        print_success "Minikube cluster is already running!"
        return 0
    fi
    
    # Start minikube
    print_status "Starting minikube cluster (this may take a few minutes)..."
    minikube start --driver=docker --memory=4096 --cpus=2
    
    # Wait for cluster to be ready
    print_status "Waiting for cluster to be ready..."
    kubectl wait --for=condition=Ready nodes --all --timeout=300s
    
    # Verify cluster
    print_status "Verifying cluster..."
    kubectl cluster-info
    kubectl get nodes
    
    print_success "Kubernetes cluster is ready!"
}

# Check if Kubernetes tools are installed
check_kubernetes_installed() {
    if command -v docker &> /dev/null && command -v kubectl &> /dev/null && command -v minikube &> /dev/null; then
        return 0  # All tools installed
    else
        return 1  # Some tools missing
    fi
}

# Check if Kubernetes cluster is running
check_kubernetes_running() {
    if kubectl cluster-info &> /dev/null; then
        return 0  # Cluster is running
    else
        return 1  # Cluster not running
    fi
}

# Main setup function
setup_environment() {
    print_status "Checking environment..."
    
    # Check if Kubernetes tools are installed
    if ! check_kubernetes_installed; then
        print_warning "Kubernetes tools not found. Installing..."
        setup_kubernetes
    else
        print_success "Kubernetes tools are already installed!"
    fi
    
    # Check if cluster is running
    if ! check_kubernetes_running; then
        print_warning "Kubernetes cluster is not running. Starting..."
        start_kubernetes_cluster
    else
        print_success "Kubernetes cluster is already running!"
    fi
}

# Create project files if they don't exist
create_project_files() {
    print_status "Checking project files..."
    
    # Check if server.js exists
    if [ ! -f "server.js" ]; then
        print_error "server.js not found!"
        print_status "Please make sure you have these files in the current directory:"
        echo "  - server.js (Node.js backend)"
        echo "  - package.json (Node.js dependencies)"
        echo "  - Dockerfile (Container configuration)"
        echo "  - k8s-deployment.yaml (Kubernetes manifests)"
        echo "  - index.html (Frontend - should be copied to public/ folder)"
        exit 1
    fi
    
    # Create public directory and copy index.html if it exists
    if [ -f "index.html" ]; then
        print_status "Creating public directory and copying frontend files..."
        mkdir -p public
        cp index.html public/
    elif [ -f "Frontend index.html" ]; then
        print_status "Found 'Frontend index.html', copying to public/index.html..."
        mkdir -p public
        cp "Frontend index.html" public/index.html
    fi
    
    print_success "Project files verified!"
}

# Build Docker image
build_image() {
    print_status "Building Docker image..."
    
    # Build the image
    docker build -t running-app:latest .
    
    if [ $? -eq 0 ]; then
        print_success "Docker image built successfully!"
        
        # Load image into minikube
        print_status "Loading image into minikube..."
        minikube image load running-app:latest
        print_success "Image loaded into minikube!"
    else
        print_error "Failed to build Docker image"
        exit 1
    fi
}

# Deploy to Kubernetes
deploy_to_k8s() {
    print_status "Deploying to Kubernetes..."
    
    # Clean up any previous deployment
    kubectl delete -f k8s-deployment.yaml --ignore-not-found=true
    sleep 5
    
    # Apply the Kubernetes manifests
    kubectl apply -f k8s-deployment.yaml
    
    if [ $? -eq 0 ]; then
        print_success "Application deployed to Kubernetes!"
    else
        print_error "Failed to deploy to Kubernetes"
        exit 1
    fi
    
    # Wait for deployment to be ready
    print_status "Waiting for deployment to be ready..."
    kubectl wait --for=condition=available --timeout=300s deployment/running-app
    
    if [ $? -eq 0 ]; then
        print_success "Deployment is ready!"
    else
        print_warning "Deployment might not be fully ready yet"
    fi
}

# Show deployment status
show_status() {
    print_status "Deployment Status:"
    echo
    
    echo "=== Pods ==="
    kubectl get pods -l app=running-app
    echo
    
    echo "=== Services ==="
    kubectl get services -l app=running-app
    echo
    
    echo "=== Deployments ==="
    kubectl get deployments -l app=running-app
    echo
    
    # Get the NodePort
    NODE_PORT=$(kubectl get service running-app-service -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null || echo "30080")
    
    print_success "🎉 Application is running!"
    echo
    echo "🌐 Access your app at:"
    echo "   http://localhost:$NODE_PORT"
    echo "   Or run: minikube service running-app-service"
    echo
    echo "📊 Useful commands:"
    echo "   kubectl logs -f deployment/running-app  # View logs"
    echo "   kubectl get pods -l app=running-app     # Check pods"
    echo "   minikube dashboard                      # Open K8s dashboard"
    echo "   minikube service running-app-service    # Open app in browser"
    echo
    echo "🧹 Cleanup commands:"
    echo "   kubectl delete -f k8s-deployment.yaml   # Remove app"
    echo "   minikube stop                           # Stop cluster"
    echo "   minikube delete                         # Delete cluster"
}

# Cleanup function
cleanup() {
    print_status "Cleaning up previous deployment..."
    kubectl delete -f k8s-deployment.yaml --ignore-not-found=true
    sleep 5
    print_success "Cleanup completed!"
}

# Complete cleanup function
complete_cleanup() {
    print_status "Performing complete cleanup..."
    
    # Remove the app
    kubectl delete -f k8s-deployment.yaml --ignore-not-found=true
    
    # Stop minikube
    print_status "Stopping minikube cluster..."
    minikube stop
    
    # Delete minikube cluster
    print_status "Deleting minikube cluster..."
    minikube delete
    
    # Clean up Docker images
    print_status "Cleaning up Docker images..."
    docker system prune -f
    
    print_success "Complete cleanup finished!"
    echo "To remove Kubernetes tools completely, run:"
    echo "  sudo rm /usr/local/bin/kubectl"
    echo "  sudo rm /usr/local/bin/minikube" 
    echo "  sudo apt remove docker-ce docker-ce-cli containerd.io"
}

# Check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        print_error "This script should not be run as root (with sudo)!"
        print_status "Minikube doesn't work well with root privileges."
        print_status "Please run without sudo: ./deploy.sh"
        print_status "The script will ask for sudo password when needed."
        exit 1
    fi
}

# Main execution
main() {
    echo "🚀 Running App Kubernetes Deployment"
    echo "======================================"
    echo
    
    # Check if running as root
    check_root
    
    # Parse command line arguments
    case "${1:-}" in
        "clean")
            cleanup
            exit 0
            ;;
        "complete-clean")
            complete_cleanup
            exit 0
            ;;
        "setup-only")
            setup_environment
            print_success "Setup complete! Run './deploy.sh' to deploy the app."
            exit 0
            ;;
        "install-tools")
            setup_kubernetes
            print_success "Kubernetes tools installed! Run './deploy.sh' to deploy the app."
            exit 0
            ;;
        *)
            # Default: full deployment
            ;;
    esac
    
    setup_environment
    create_project_files
    build_image
    deploy_to_k8s
    show_status
    
    print_success "🎉 Deployment complete!"
    echo
    echo "🎯 Quick commands:"
    echo "  ./deploy.sh clean              # Clean up app only"
    echo "  ./deploy.sh complete-clean     # Clean up everything"
    echo "  ./deploy.sh setup-only         # Setup K8s tools only"
    echo "  ./deploy.sh install-tools      # Install tools only"
}

# Run main function
main "$@"