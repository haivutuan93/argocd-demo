# Jenkins Setup Guide

## 🚀 Cài đặt Jenkins

```bash
./scripts/setup-jenkins.sh
```

## 🔑 Lấy Initial Admin Password

```bash
kubectl exec -it $(kubectl get pods -n jenkins -l app=jenkins -o jsonpath='{.items[0].metadata.name}') -n jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword
```

## 📋 Các bước setup Jenkins

### 1. Truy cập Jenkins
- URL: http://localhost:30800
- Nhập Initial Admin Password

### 2. Cài đặt Plugins
Chọn "Install suggested plugins" và đợi cài đặt xong.

Sau đó cài thêm các plugins:
- Docker Pipeline
- Pipeline
- Git
- Credentials Binding

### 3. Tạo Admin User
Điền thông tin admin user.

### 4. Thêm GitHub Credentials

1. Vào **Manage Jenkins** → **Credentials** → **System** → **Global credentials**
2. Click **Add Credentials**
3. Điền:
   - **Kind**: Username with password
   - **Scope**: Global
   - **Username**: `haivutuan93` (GitHub username)
   - **Password**: GitHub Personal Access Token
   - **ID**: `github-credentials`
   - **Description**: GitHub credentials for argocd-demo

### 5. Tạo Personal Access Token trên GitHub

1. Vào https://github.com/settings/tokens
2. **Generate new token (classic)**
3. Chọn scopes:
   - `repo` (Full control of private repositories)
4. Copy token và dùng làm password ở bước 4

### 6. Tạo Pipeline Job

1. Click **New Item**
2. Nhập tên: `argocd-demo-pipeline`
3. Chọn **Pipeline** → OK
4. Trong **Pipeline** section:
   - **Definition**: Pipeline script from SCM
   - **SCM**: Git
   - **Repository URL**: `https://github.com/haivutuan93/argocd-demo.git`
   - **Credentials**: Chọn credentials vừa tạo
   - **Branch**: `*/main`
   - **Script Path**: `Jenkinsfile`
5. **Save**

## 🎯 Sử dụng Pipeline

### Build thủ công
1. Vào job `argocd-demo-pipeline`
2. Click **Build with Parameters**
3. Nhập VERSION (hoặc để trống để auto-generate)
4. Click **Build**

### Xem logs
Click vào build number → **Console Output**

## 🔄 Flow hoàn chỉnh

```
Developer push code
        ↓
User vào Jenkins bấm "Build"
        ↓
Jenkins:
  1. Checkout code từ GitHub
  2. Build với Maven
  3. Build Docker image
  4. Push image → localhost:30500
  5. Update values.yaml
  6. Commit & Push → GitHub
        ↓
ArgoCD polls GitHub (mỗi 3 phút)
        ↓
ArgoCD sync → Deploy lên K8s
        ↓
App chạy tại http://localhost:30080
```

## 🛠 Troubleshooting

### Jenkins không start được
```bash
kubectl logs -f deployment/jenkins -n jenkins
kubectl describe pod -l app=jenkins -n jenkins
```

### Docker build failed
```bash
# Kiểm tra Docker socket
kubectl exec -it $(kubectl get pods -n jenkins -l app=jenkins -o jsonpath='{.items[0].metadata.name}') -n jenkins -- docker ps
```

### Push to registry failed
```bash
# Kiểm tra registry đang chạy
kubectl get pods -n docker-registry
curl http://localhost:30500/v2/_catalog
```

