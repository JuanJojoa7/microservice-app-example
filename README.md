# Microservices with Cloud Patterns

Implementation of **Circuit Breaker** and **Cache Aside** patterns for a microservices architecture using Docker, Azure, and automated CI/CD pipelines.

## Quick Start

### 1. Prerequisites
- GitHub repository with secrets configured
- Azure subscription
- Docker Hub account

### 2. Required GitHub Secrets

Configure these secrets in your repository (`Settings → Secrets → Actions`):

```
AZURE_CREDENTIALS          # Azure service principal credentials (JSON)
DOCKERHUB_USERNAME         # Your Docker Hub username
DOCKERHUB_TOKEN           # Docker Hub access token
```

**Azure Credentials Format:**
```json
{
  "clientId": "your-client-id",
  "clientSecret": "your-client-secret",
  "subscriptionId": "your-subscription-id",
  "tenantId": "your-tenant-id"
}
```

### 3. Deploy Infrastructure

1. Go to **Actions** tab
2. Select **"Infrastructure Pipeline"**
3. Click **"Run workflow"**
4. Choose action: **"deploy"**
5. Click **"Run workflow"**

Wait 5-10 minutes for Azure VM creation and setup.

### 4. Deploy Application

1. Go to **Actions** tab  
2. Select **"Development Pipeline"**
3. Click **"Run workflow"**
4. Choose action: **"deploy"**
5. Click **"Run workflow"**

Wait 10-15 minutes for Docker builds and deployment.

### 5. Access Application

After successful deployment, check the Actions logs for:

- **Application**: `http://YOUR-AZURE-VM-IP`
- **Dashboard**: `http://YOUR-AZURE-VM-IP:8404/stats`
- **Login**: `admin` / `admin`

## Local Development

### Demo with Patterns
```bash
# Windows
presentacion-final.bat

# Linux/Mac
docker-compose -f docker-compose-simple.yml up -d
```

### Compare With/Without Patterns
```bash
# Windows
comparacion-patrones.bat

# Linux/Mac
docker-compose -f docker-compose-sin-patrones.yml up -d  # Without patterns
docker-compose -f docker-compose-simple.yml up -d        # With patterns
```

**Local Access:**
- Application: http://localhost
- Dashboard: http://localhost:8404/stats

## Architecture

```
Internet → HAProxy (Circuit Breaker) → Microservices
                                    ↘ Redis (Cache Aside)
```

### Services
- **Frontend**: Vue.js (port 8081)
- **Auth API**: Go (port 8000)  
- **Users API**: Java/Spring Boot (port 8083)
- **TODOs API**: Node.js (port 8082)
- **Log Processor**: Python
- **Redis**: Cache + Message Queue (port 6379)
- **HAProxy**: Load Balancer + Circuit Breaker (ports 80, 8404)

## Patterns Implemented

### Circuit Breaker (HAProxy)
- **Without**: 30-60s timeout when service fails
- **With**: <1s response with clear error (503)
- **Auto-recovery**: Detects healthy services automatically

### Cache Aside (Redis)
- **Without**: ~500ms per query (always database)
- **With**: ~1-5ms for repeated queries (99% improvement)
- **Fallback**: Automatic database access if cache fails

## Infrastructure

- **Cloud**: Azure VM (Standard_B2s - 2 vCPUs, 4GB RAM)
- **Cost**: ~$18-25 USD/month
- **Region**: East US 2
- **OS**: Ubuntu 22.04 LTS
- **Provisioning**: Terraform (Infrastructure as Code)

## Pipeline Actions

### Infrastructure Pipeline
- `plan`: Preview infrastructure changes
- `deploy`: Create Azure resources
- `destroy`: Remove all Azure resources  
- `clean-deploy`: Full recreation (delete + create)

### Development Pipeline
- `deploy`: Build images, push to Docker Hub, deploy to Azure
- `test-only`: Run tests without deployment

## Cleanup

To destroy all Azure resources:

1. Go to **Actions** → **Infrastructure Pipeline**
2. **Run workflow** with action: **"destroy"**

## Troubleshooting

### Common Issues

**Pipeline fails with Azure authentication:**
- Verify `AZURE_CREDENTIALS` secret is correctly formatted
- Ensure service principal has Contributor role

**Docker build fails:**
- Check `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets
- Verify Docker Hub repository exists and is accessible

**Application not accessible:**
- Wait 5-10 minutes after deployment
- Check Azure VM is running in Azure Portal
- Verify Network Security Group allows traffic on ports 80, 8404

**Services not starting:**
- SSH to VM: `ssh azureuser@YOUR-VM-IP` (password: `MicroservicesDemo2025!`)
- Check containers: `sudo docker ps`
- View logs: `sudo docker-compose logs`

### Manual VM Access

```bash
# SSH to Azure VM (get IP from Actions logs)
ssh azureuser@YOUR-VM-IP
# Password: MicroservicesDemo2025!

# Check application status
cd microservice-app-example
sudo docker ps
sudo docker-compose logs
```

## Project Structure

```
microservice-app-example/
├── .github/workflows/          # CI/CD pipelines
│   ├── infrastructure.yml      # Terraform deployment
│   └── development.yml         # Application deployment
├── terraform/                  # Azure infrastructure
├── [microservices]/           # 5 original services (unchanged)
├── docker-compose-*.yml       # Container configurations  
├── haproxy-simple.cfg         # Circuit Breaker config
├── presentacion-final.bat     # Demo script
└── comparacion-patrones.bat   # Comparison demo
```

## Key Features

- ✅ **Zero code changes** to original microservices
- ✅ **Fully automated** infrastructure and deployment
- ✅ **Measurable improvements** in performance and reliability
- ✅ **Cost-optimized** Azure infrastructure
- ✅ **Production-ready** with monitoring dashboard
- ✅ **Local development** support with demo scripts

---

**Need help?** Check the Actions logs or create an issue in this repository.

## New Architecture

![microservice-app-example](/arch-img/Microservices.png)
 
 
 

## Old Architecture

Take a look at the components diagram that describes them and their interactions. L
![New Diagrama](/arch-img/Diagrama.svg) L
