# ArgoCD Demo - Spring Boot Application

Dự án demo sử dụng ArgoCD để deploy ứng dụng Java Spring Boot lên Kubernetes (Docker Desktop).

## 📁 Cấu trúc Project

```
argocd-demo/
├── src/                          # Source code Spring Boot
│   └── main/
│       ├── java/
│       │   └── com/demo/argocd/
│       │       ├── ArgoCdDemoApplication.java
│       │       └── controller/
│       │           └── HelloController.java
│       └── resources/
│           └── application.yml
├── helm/                         # Helm Chart
│   └── argocd-demo/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── serviceaccount.yaml
│           ├── configmap.yaml
│           ├── hpa.yaml
│           └── ingress.yaml
├── argocd/                       # ArgoCD manifests
│   ├── application.yaml
│   ├── application-local.yaml
│   ├── namespace.yaml
│   └── project.yaml
├── scripts/                      # Helper scripts
│   ├── install-argocd.sh
│   ├── build-docker.sh
│   ├── deploy-manual.sh
│   ├── deploy-argocd.sh
│   └── cleanup.sh
├── Dockerfile
├── pom.xml
└── README.md
```

## 🛠 Yêu cầu

- Docker Desktop với Kubernetes enabled
- kubectl
- Helm 3.x
- Maven 3.x (hoặc sử dụng Docker để build)
- Java 17+ (nếu build local)

## 🚀 Hướng dẫn Setup

### 1. Bật Kubernetes trên Docker Desktop

1. Mở Docker Desktop
2. Vào Settings → Kubernetes
3. Check "Enable Kubernetes"
4. Apply & Restart

Verify Kubernetes đang chạy:
```bash
kubectl cluster-info
kubectl get nodes
```

### 2. Cài đặt ArgoCD

```bash
# Cấp quyền execute cho scripts
chmod +x scripts/*.sh

# Cài đặt ArgoCD
./scripts/install-argocd.sh
```

Script sẽ:
- Tạo namespace `argocd`
- Cài đặt ArgoCD
- Hiển thị password admin

### 3. Truy cập ArgoCD UI

```bash
# Port-forward ArgoCD server
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Mở browser: https://localhost:8080
- Username: `admin`
- Password: (lấy từ script install hoặc chạy lệnh bên dưới)

```bash
# Lấy password admin
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## 🐳 Build Docker Image

### Option 1: Sử dụng script

```bash
./scripts/build-docker.sh 1.0.0
```

### Option 2: Build thủ công

```bash
# Build với tag version
docker build -t argocd-demo:1.0.0 .

# Hoặc build với latest
docker build -t argocd-demo:latest .
```

### Test Docker image locally

```bash
docker run -p 8080:8080 argocd-demo:latest
```

Truy cập: http://localhost:8080

## 📦 Deploy

### Option 1: Deploy trực tiếp với Helm (không qua ArgoCD)

```bash
./scripts/deploy-manual.sh
```

Hoặc chạy thủ công:

```bash
# Tạo namespace
kubectl create namespace argocd-demo

# Deploy với Helm
helm upgrade --install argocd-demo ./helm/argocd-demo \
  --namespace argocd-demo \
  --set image.repository=argocd-demo \
  --set image.tag=latest \
  --set image.pullPolicy=Never
```

### Option 2: Deploy qua ArgoCD (GitOps)

#### Bước 1: Push code lên Git repository

```bash
# Khởi tạo git repo
git init
git add .
git commit -m "Initial commit"

# Push lên GitHub/GitLab
git remote add origin https://github.com/YOUR_USERNAME/argocd-demo.git
git push -u origin main
```

#### Bước 2: Cập nhật ArgoCD Application

Sửa file `argocd/application.yaml`:
```yaml
spec:
  source:
    repoURL: https://github.com/YOUR_USERNAME/argocd-demo.git  # ← Thay bằng URL repo của bạn
```

#### Bước 3: Apply ArgoCD Application

```bash
kubectl apply -f argocd/application.yaml
```

Hoặc sử dụng script:
```bash
./scripts/deploy-argocd.sh
```

## 🔍 Kiểm tra Deployment

```bash
# Xem pods
kubectl get pods -n argocd-demo

# Xem services
kubectl get svc -n argocd-demo

# Xem logs
kubectl logs -l app.kubernetes.io/name=argocd-demo -n argocd-demo

# Xem ArgoCD Application status
kubectl get application argocd-demo -n argocd
```

## 🌐 Truy cập ứng dụng

### Qua NodePort
```
http://localhost:30080
```

### Qua Port-forward
```bash
kubectl port-forward svc/argocd-demo -n argocd-demo 8080:80
```
Truy cập: http://localhost:8080

## 📡 API Endpoints

| Endpoint | Method | Mô tả |
|----------|--------|-------|
| `/` | GET | Hello message với version và environment |
| `/health` | GET | Health check |
| `/info` | GET | Application info |
| `/actuator/health` | GET | Spring Actuator health |

## 🔄 GitOps Workflow

1. **Thay đổi code** → Commit & Push lên Git
2. **ArgoCD detect** → Tự động sync (nếu enabled auto-sync)
3. **Helm deploy** → Update Kubernetes resources
4. **Rolling update** → Zero-downtime deployment

### Test GitOps flow

1. Sửa `helm/argocd-demo/values.yaml`:
```yaml
app:
  version: "2.0.0"  # Thay đổi version
```

2. Commit và push:
```bash
git add .
git commit -m "Update app version to 2.0.0"
git push
```

3. Quan sát ArgoCD UI hoặc:
```bash
kubectl get application argocd-demo -n argocd -w
```

## 🧹 Dọn dẹp

```bash
./scripts/cleanup.sh
```

Hoặc xóa thủ công:

```bash
# Xóa ArgoCD Application
kubectl delete application argocd-demo -n argocd

# Xóa namespace
kubectl delete namespace argocd-demo

# Xóa ArgoCD (optional)
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl delete namespace argocd
```

## 📚 Tài liệu tham khảo

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Helm Documentation](https://helm.sh/docs/)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## 🐛 Troubleshooting

### Pod không start được

```bash
# Xem events
kubectl describe pod -l app.kubernetes.io/name=argocd-demo -n argocd-demo

# Xem logs
kubectl logs -l app.kubernetes.io/name=argocd-demo -n argocd-demo --previous
```

### ArgoCD Application stuck at "Progressing"

```bash
# Check sync status
kubectl describe application argocd-demo -n argocd

# Manual sync
kubectl patch application argocd-demo -n argocd --type merge -p '{"operation": {"initiatedBy": {"username": "admin"}, "sync": {}}}'
```

### Image pull error

Với Docker Desktop, đảm bảo sử dụng `imagePullPolicy: Never` cho local images:

```bash
helm upgrade --install argocd-demo ./helm/argocd-demo \
  --set image.pullPolicy=Never
```

