# 🚀 AZURE DEPLOYMENT - INFRAESTRUCTURA Y CI/CD

Esta guía te permite desplegar la aplicación de microservicios en Azure con **Terraform** y **GitHub Actions** de forma completamente automatizada.

## 💰 COSTO ESTIMADO: ~$7-10 USD/mes

La configuración usa la **VM más barata** de Azure:
- **Standard_B1s**: 1 vCPU, 1 GB RAM
- **Standard_LRS**: Disco estándar 
- **East US**: Región más económica
- **Ubuntu 22.04 LTS**: Sistema operativo gratuito

---

## 🔧 CONFIGURACIÓN INICIAL (Una sola vez)

### 1. 🔐 Configurar Secretos de GitHub

Ve a tu repositorio → **Settings** → **Secrets and variables** → **Actions** y agrega:

```bash
# AZURE_CREDENTIALS (Service Principal)
{
  "clientId": "tu-client-id",
  "clientSecret": "tu-client-secret", 
  "subscriptionId": "tu-subscription-id",
  "tenantId": "tu-tenant-id"
}
```

### 2. 📋 Crear Service Principal en Azure

```bash
# Ejecutar en Azure CLI
az login
az account set --subscription "tu-subscription-id"

# Crear service principal
az ad sp create-for-rbac \
  --name "sp-microservices-terraform" \
  --role "Contributor" \
  --scopes "/subscriptions/tu-subscription-id" \
  --sdk-auth

# Copiar la salida JSON completa a AZURE_CREDENTIALS
```

### 3. ✅ Verificar Permisos

El Service Principal necesita permisos para:
- ✅ Crear recursos en Azure (Contributor)
- ✅ Administrar redes y VMs
- ✅ Crear grupos de recursos

---

## 🚀 DESPLIEGUE AUTOMÁTICO

### OPCIÓN 1: Pipeline Manual (Recomendado para primera vez)

1. **Ve a GitHub Actions** en tu repositorio
2. **Selecciona "🏗️ Infrastructure Pipeline"**
3. **Click "Run workflow"**
4. **Selecciona acción: "deploy"**
5. **Ejecutar**

### OPCIÓN 2: Push Automático

Simplemente haz **push** a la rama `feature/infrastructure-setup`:

```bash
git add .
git commit -m "Deploy infrastructure and app"
git push origin feature/infrastructure-setup
```

**El pipeline se ejecuta automáticamente y:**
1. 🧪 **Tests**: Valida todos los microservicios
2. 🏗️ **Infrastructure**: Crea VM en Azure con Terraform
3. 🚀 **Deploy**: Despliega aplicación con Docker
4. ✅ **Verify**: Confirma que todo funciona

---

## 📊 PIPELINES DISPONIBLES

### 🏗️ Infrastructure Pipeline
**Archivo**: `.github/workflows/infrastructure.yml`

**Funciones**:
- ✅ **Plan**: Muestra qué se va a crear/cambiar
- ✅ **Deploy**: Crea infraestructura en Azure 
- ✅ **Destroy**: Elimina todo (ahorra dinero)

**Triggers**:
- Manual: GitHub Actions → "Run workflow"
- Automático: Push a archivos `terraform/**`

### 🚀 Development Pipeline  
**Archivo**: `.github/workflows/development.yml`

**Funciones**:
- ✅ **Test**: Valida todos los microservicios
- ✅ **Build**: Construye imágenes Docker
- ✅ **Deploy**: Actualiza aplicación en VM

**Triggers**:
- Manual: GitHub Actions → "Run workflow"  
- Automático: Push a código de aplicación

---

## 🌐 ACCESO A LA APLICACIÓN

Después del despliegue exitoso:

### 📱 URLs Disponibles:
- **🌐 Aplicación**: `http://TU-IP-PUBLICA`
- **📊 Dashboard**: `http://TU-IP-PUBLICA:8404/stats`

### 👤 Credenciales:
- **Usuario**: `admin`
- **Contraseña**: `admin`

### 🔐 SSH a la VM:
```bash
ssh azureuser@TU-IP-PUBLICA
# Contraseña: MicroservicesDemo2025!
```

---

## 🎯 DEMO EN VIVO - COMANDOS

### 1. 🔄 Actualizar Aplicación
```bash
# En la VM via SSH
cd /home/azureuser/microservices-app
./deploy-app.sh
```

### 2. 📊 Monitorear Servicios
```bash
# Ver contenedores corriendo
docker ps

# Ver logs en tiempo real
docker-compose -f docker-compose-simple.yml logs -f

# Ver uso de recursos
docker stats
```

### 3. 🧪 Probar Patrones
```bash
# En la VM (adaptar scripts .bat a Linux)
# Circuit Breaker test
docker stop microservices_auth
curl http://localhost  # Debería dar 503
docker start microservices_auth

# Cache test
docker exec microservices_redis redis-cli FLUSHALL
docker exec microservices_redis redis-cli SET "test" "cached-data"
docker exec microservices_redis redis-cli GET "test"
```

---

## 💰 AHORRO DE COSTOS

### 🗑️ Eliminar Infraestructura (Cuando no uses)
```bash
# Opción 1: GitHub Actions
# Ir a "Infrastructure Pipeline" → Run workflow → "destroy"

# Opción 2: Terraform local
cd terraform
terraform destroy -auto-approve
```

### 📊 Monitoreo de Costos
- **Azure Portal** → Cost Management
- **Alertas**: Configura alertas si supera $15/mes
- **Apagar VM**: En horarios no laborales para ahorrar

---

## 🚨 TROUBLESHOOTING

### ❌ Error: "Resource already exists"
```bash
# Limpiar estado de Terraform
cd terraform
rm -rf .terraform terraform.tfstate*
terraform init
```

### ❌ Error: "Service Principal permissions"
```bash
# Verificar permisos
az role assignment list --assignee "tu-client-id"
```

### ❌ Error: "VM not responding"
```bash
# SSH a la VM y revisar logs
ssh azureuser@IP-PUBLICA
sudo journalctl -f
docker ps
```

### ❌ Error: "Application not loading"
```bash
# En la VM
cd /home/azureuser/microservices-app
docker-compose -f docker-compose-simple.yml down
docker-compose -f docker-compose-simple.yml up -d --build
```

---

## 📚 ARCHIVOS IMPORTANTES

### Terraform:
- `terraform/main.tf` - Infraestructura Azure
- `terraform/outputs.tf` - Variables de salida
- `terraform/terraform.tfvars` - Configuración personalizable

### Pipelines:
- `.github/workflows/infrastructure.yml` - Pipeline infraestructura
- `.github/workflows/development.yml` - Pipeline aplicación

### Scripts Locales:
- `presentacion-final.bat` - Demo completa local
- `comparacion-patrones.bat` - Comparación con/sin patrones
- `servicios.bat` - Control manual servicios

---

## 🎉 ¡LISTO PARA PRESENTACIÓN!

Una vez desplegado tienes:

✅ **Infraestructura como código** (Terraform)  
✅ **CI/CD completamente automatizado** (GitHub Actions)  
✅ **Aplicación en la nube** (Azure VM)  
✅ **Patrones de nube funcionando** (Circuit Breaker + Cache Aside)  
✅ **Monitoreo en tiempo real** (HAProxy Dashboard)  
✅ **Costos controlados** (~$7-10/mes)  

**¡Todo automatizado, sin tocar Azure Portal manualmente!** 🚀