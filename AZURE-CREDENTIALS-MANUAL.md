# 🔧 GUÍA MANUAL: Obtener Credenciales de Azure

Si prefieres obtener las credenciales manualmente, sigue estos pasos:

## 📋 PASO 1: Instalar herramientas necesarias

### Azure CLI
```powershell
# Opción 1: Winget (recomendado)
winget install Microsoft.AzureCLI

# Opción 2: Descargar
# Ir a: https://aka.ms/InstallAzureCLI
```

### GitHub CLI
```powershell
# Opción 1: Winget (recomendado)  
winget install GitHub.cli

# Opción 2: Descargar
# Ir a: https://cli.github.com/
```

## 📋 PASO 2: Login a Azure

```powershell
# Login a Azure
az login

# Verificar que funciona
az account show
```

## 📋 PASO 3: Obtener información básica

```powershell
# Obtener Subscription ID
az account show --query "id" -o tsv

# Obtener Tenant ID  
az account show --query "tenantId" -o tsv
```

**Guarda estos valores:**
- `AZURE_SUBSCRIPTION_ID` = [salida del primer comando]
- `AZURE_TENANT_ID` = [salida del segundo comando]

## 📋 PASO 4: Crear Service Principal

```powershell
# Crear Service Principal (cambia 'tu-subscription-id' por el valor real)
az ad sp create-for-rbac \
  --name "sp-microservices-terraform" \
  --role "Contributor" \
  --scopes "/subscriptions/TU-SUBSCRIPTION-ID" \
  --sdk-auth
```

**La salida será un JSON como este:**
```json
{
  "clientId": "abcd1234-...",
  "clientSecret": "xyz789...", 
  "subscriptionId": "efgh5678-...",
  "tenantId": "ijkl9012-..."
}
```

**Guarda estos valores:**
- `AZURE_CLIENT_ID` = valor de "clientId"
- `AZURE_CLIENT_SECRET` = valor de "clientSecret"

## 📋 PASO 5: Configurar secretos en GitHub

### Via GitHub Web (Más fácil)
1. Ve a tu repositorio en GitHub
2. Settings → Secrets and variables → Actions
3. "New repository secret" para cada uno:

```
Nombre: AZURE_CLIENT_ID
Valor: [tu-client-id]

Nombre: AZURE_CLIENT_SECRET  
Valor: [tu-client-secret]

Nombre: AZURE_SUBSCRIPTION_ID
Valor: [tu-subscription-id]

Nombre: AZURE_TENANT_ID
Valor: [tu-tenant-id]
```

### Via GitHub CLI (Alternativo)
```powershell
# Login a GitHub
gh auth login

# Configurar secretos
gh secret set AZURE_CLIENT_ID --body "tu-client-id"
gh secret set AZURE_CLIENT_SECRET --body "tu-client-secret"  
gh secret set AZURE_SUBSCRIPTION_ID --body "tu-subscription-id"
gh secret set AZURE_TENANT_ID --body "tu-tenant-id"

# Verificar
gh secret list
```

## ✅ VERIFICACIÓN

Deberías ver 4 secretos en GitHub:
- ✅ AZURE_CLIENT_ID
- ✅ AZURE_CLIENT_SECRET  
- ✅ AZURE_SUBSCRIPTION_ID
- ✅ AZURE_TENANT_ID

## 🚀 SIGUIENTE PASO

Una vez configurados los secretos:

1. **Hacer commit y push**:
```bash
git add .
git commit -m "feat: Add Azure infrastructure automation"
git push origin feature/infrastructure-setup
```

2. **Ejecutar pipeline**:
   - GitHub → Actions → "Infrastructure Pipeline" → "Run workflow" → "deploy"

3. **¡Disfrutar aplicación en Azure!**

---

## 🚨 TROUBLESHOOTING

### Error: "insufficient privileges"
```powershell
# Verificar permisos del Service Principal
az role assignment list --assignee "tu-client-id"

# Si no tiene permisos, agregar:
az role assignment create \
  --assignee "tu-client-id" \
  --role "Contributor" \
  --scope "/subscriptions/tu-subscription-id"
```

### Error: "Service Principal not found"
```powershell
# Listar Service Principals
az ad sp list --display-name "sp-microservices-terraform"

# Si no existe, crear nuevamente
az ad sp create-for-rbac --name "sp-microservices-terraform"
```

### Error: "GitHub CLI not authenticated"
```powershell
# Re-login a GitHub
gh auth logout
gh auth login
```

---

## 💡 TIP: Usar script automático

Para evitar estos pasos manuales, simplemente ejecuta:
```cmd
setup-github-secrets.bat
```

¡Y todo se configura automáticamente! 🚀