# Simple Python Application

A lightweight Flask application designed for deployment in Kind (Kubernetes in Docker) clusters with NodePort service.

## Features

- ✅ Simple Flask REST API
- ✅ Health and readiness endpoints
- ✅ Docker containerized
- ✅ Kubernetes ready (deployment + NodePort service)
- ✅ Lightweight (minimal dependencies)

## Endpoints

- `GET /` - Main endpoint returning app info
- `GET /health` - Health check endpoint
- `GET /ready` - Readiness check endpoint

## Local Development
## test fork

1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Run locally:**
   ```bash
   python app.py
   ```

3. **Test:**
   ```bash
   curl http://localhost:8080
   ```

## Build Docker Image

```bash
docker build -t simple-app:latest .
```

## Deploy to Kind Cluster

### 1. Create Kind Cluster (if not exists)

```bash
kind create cluster --name simple-app-cluster
```

### 2. Load Image into Kind

```bash
kind load docker-image simple-app:latest --name simple-app-cluster
```

### 3. Deploy Application

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

### 4. Verify Deployment

```bash
# Check pods
kubectl get pods

# Check service
kubectl get svc simple-app

# Check deployment
kubectl get deployment simple-app
```

### 5. Access the Application

**Option A: Port Forward (recommended for local development)**
```bash
kubectl port-forward service/simple-app 8080:80
```
Then access at: http://localhost:8080

**Option B: NodePort Access**
```bash
# Get the node IP
kubectl get nodes -o wide

# Access via NodePort
curl http://<node-ip>:30080
```

For Kind clusters, you can access via:
```bash
curl http://localhost:30080
```

**Option C: Cloud Forward (for cloud deployments)**

If deploying to cloud providers (GKE, EKS, AKS), you can use port-forward:
```bash
# Forward from cloud
kubectl port-forward service/simple-app 8080:80

# Or expose via LoadBalancer (cloud only)
kubectl patch service simple-app -p '{"spec":{"type":"LoadBalancer"}}'
```

## Cleanup

```bash
# Delete Kubernetes resources
kubectl delete -f k8s/

# Delete Kind cluster
kind delete cluster --name simple-app-cluster
```

## Scaling

```bash
# Scale up/down
kubectl scale deployment simple-app --replicas=3
```

## Cloud Deployment Notes

### AWS EKS
- NodePort will work within VPC
- For external access, use LoadBalancer or Ingress

### GCP GKE
- NodePort accessible within GCP network
- Use LoadBalancer for external access

### Azure AKS
- NodePort available within VNET
- LoadBalancer recommended for public access

### Port Forwarding in Cloud
```bash
# Forward service port to local machine
kubectl port-forward service/simple-app 8080:80

# Forward specific pod
kubectl port-forward pod/<pod-name> 8080:8080
```

## Monitoring

```bash
# Watch pods
kubectl get pods -w

# View logs
kubectl logs -f deployment/simple-app

# Describe service
kubectl describe service simple-app
```
