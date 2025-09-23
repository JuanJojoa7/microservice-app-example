# Script de configuración para Azure + GitHub (PowerShell)
# ============================================================

Write-Host "================================================================"
Write-Host "   🔧 CONFIGURACIÓN AUTOMÁTICA AZURE + GITHUB"
Write-Host "   Obtener credenciales y configurar secretos"
Write-Host "================================================================"
Write-Host ""

Write-Host "📋 PASO 1: Verificando herramientas..." -ForegroundColor Yellow

# Verificar Azure CLI
Write-Host "🔍 Verificando Azure CLI..." -ForegroundColor Cyan
try {
    $azVersion = az --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Azure CLI no encontrado"
    }
    Write-Host "✅ Azure CLI encontrado" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI no instalado" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 SOLUCIÓN:" -ForegroundColor Yellow
    Write-Host "   1. Ejecutar: winget install Microsoft.AzureCLI"
    Write-Host "   2. O descargar desde: https://aka.ms/InstallAzureCLI"
    Write-Host "   3. Reiniciar PowerShell después de instalar"
    Write-Host ""
    Read-Host "Presiona Enter después de instalar Azure CLI..."
    exit 1
}

# Verificar GitHub CLI
Write-Host "🔍 Verificando GitHub CLI..." -ForegroundColor Cyan
$ghPath = $null

# Buscar en rutas comunes
$possiblePaths = @(
    "C:\Program Files\GitHub CLI\gh.exe",
    "C:\Program Files (x86)\GitHub CLI\gh.exe",
    "$env:USERPROFILE\AppData\Local\Programs\GitHub CLI\gh.exe"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $ghPath = $path
        break
    }
}

# Verificar si está en PATH
if (-not $ghPath) {
    try {
        $ghCommand = Get-Command gh -ErrorAction Stop
        $ghPath = $ghCommand.Source
    } catch {
        # No está en PATH
    }
}

if (-not $ghPath) {
    Write-Host "❌ GitHub CLI no encontrado" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 SOLUCIÓN:" -ForegroundColor Yellow
    Write-Host "   1. Ejecutar: winget install GitHub.cli"
    Write-Host "   2. O descargar desde: https://cli.github.com/"
    Write-Host "   3. CERRAR Y ABRIR PowerShell después de instalar"
    Write-Host ""
    $respuesta = Read-Host "¿Ya instalaste GitHub CLI? (Y/N)"
    if ($respuesta -eq "Y" -or $respuesta -eq "y") {
        Write-Host ""
        Write-Host "⚠️  CIERRA PowerShell y ábrelo de nuevo, luego ejecuta:" -ForegroundColor Yellow
        Write-Host "   .\setup-github-secrets-powershell.ps1"
        Write-Host ""
    }
    Read-Host "Presiona Enter para continuar..."
    exit 1
}

Write-Host "✅ GitHub CLI encontrado: $ghPath" -ForegroundColor Green
Write-Host ""

# Verificar autenticación GitHub
Write-Host "📋 PASO 2: Verificando autenticación GitHub..." -ForegroundColor Yellow
try {
    & $ghPath auth status 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ No estás autenticado en GitHub" -ForegroundColor Red
        Write-Host "🔐 Ejecutando autenticación..." -ForegroundColor Cyan
        & $ghPath auth login
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Error en autenticación" -ForegroundColor Red
            Read-Host "Presiona Enter para continuar..."
            exit 1
        }
    }
    Write-Host "✅ GitHub CLI autenticado" -ForegroundColor Green
} catch {
    Write-Host "❌ Error verificando autenticación GitHub" -ForegroundColor Red
    exit 1
}

# Login a Azure
Write-Host "📋 PASO 3: Login a Azure..." -ForegroundColor Yellow
try {
    az account show 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "🔐 Abriendo login de Azure..." -ForegroundColor Cyan
        az login
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Error en login de Azure" -ForegroundColor Red
            Read-Host "Presiona Enter para continuar..."
            exit 1
        }
    }
    Write-Host "✅ Login a Azure exitoso" -ForegroundColor Green
} catch {
    Write-Host "❌ Error en login de Azure" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Obtener información de Azure
Write-Host "📋 PASO 4: Obteniendo información de Azure..." -ForegroundColor Yellow
Write-Host "📊 Obteniendo datos de suscripción..." -ForegroundColor Cyan

try {
    $AZURE_SUBSCRIPTION_ID = az account show --query "id" -o tsv
    $AZURE_TENANT_ID = az account show --query "tenantId" -o tsv
    
    Write-Host "✅ Subscription ID: $AZURE_SUBSCRIPTION_ID" -ForegroundColor Green
    Write-Host "✅ Tenant ID: $AZURE_TENANT_ID" -ForegroundColor Green
} catch {
    Write-Host "❌ Error obteniendo información de Azure" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Crear Service Principal
Write-Host "📋 PASO 5: Creando Service Principal..." -ForegroundColor Yellow

$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$SP_NAME = "sp-microservices-$timestamp"

Write-Host "🔧 Creando Service Principal: $SP_NAME" -ForegroundColor Cyan

try {
    az ad sp create-for-rbac --name $SP_NAME --role "Contributor" --scopes "/subscriptions/$AZURE_SUBSCRIPTION_ID" --sdk-auth > sp-credentials.json
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Error creando Service Principal" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✅ Service Principal creado exitosamente" -ForegroundColor Green
} catch {
    Write-Host "❌ Error creando Service Principal" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Extraer credenciales
Write-Host "📋 PASO 6: Extrayendo credenciales..." -ForegroundColor Yellow

try {
    $json = Get-Content 'sp-credentials.json' | ConvertFrom-Json
    $AZURE_CLIENT_ID = $json.clientId
    $AZURE_CLIENT_SECRET = $json.clientSecret
    
    Write-Host "✅ Client ID: $AZURE_CLIENT_ID" -ForegroundColor Green
    Write-Host "✅ Client Secret: [HIDDEN]" -ForegroundColor Green
} catch {
    Write-Host "❌ Error extrayendo credenciales" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Configurar secretos en GitHub
Write-Host "📋 PASO 7: Configurando secretos en GitHub..." -ForegroundColor Yellow

try {
    Write-Host "🔧 Configurando AZURE_CLIENT_ID..." -ForegroundColor Cyan
    $AZURE_CLIENT_ID | & $ghPath secret set AZURE_CLIENT_ID
    
    Write-Host "🔧 Configurando AZURE_CLIENT_SECRET..." -ForegroundColor Cyan
    $AZURE_CLIENT_SECRET | & $ghPath secret set AZURE_CLIENT_SECRET
    
    Write-Host "🔧 Configurando AZURE_SUBSCRIPTION_ID..." -ForegroundColor Cyan
    $AZURE_SUBSCRIPTION_ID | & $ghPath secret set AZURE_SUBSCRIPTION_ID
    
    Write-Host "🔧 Configurando AZURE_TENANT_ID..." -ForegroundColor Cyan
    $AZURE_TENANT_ID | & $ghPath secret set AZURE_TENANT_ID
    
    Write-Host "✅ Todos los secretos configurados" -ForegroundColor Green
} catch {
    Write-Host "❌ Error configurando secretos" -ForegroundColor Red
    Write-Host "Detalles: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Verificar configuración
Write-Host "📋 PASO 8: Verificando configuración..." -ForegroundColor Yellow

try {
    $secrets = & $ghPath secret list
    if ($secrets -match "AZURE") {
        Write-Host "✅ Secretos verificados en GitHub" -ForegroundColor Green
    } else {
        Write-Host "⚠️ No se pudieron verificar los secretos, pero deberían estar configurados" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️ No se pudieron verificar los secretos, pero deberían estar configurados" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 ¡CONFIGURACIÓN COMPLETADA!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""
Write-Host "✅ Service Principal creado: $SP_NAME" -ForegroundColor Green
Write-Host "✅ Credenciales extraídas automáticamente" -ForegroundColor Green
Write-Host "✅ Secretos configurados en GitHub Repository" -ForegroundColor Green
Write-Host ""
Write-Host "📊 RESUMEN DE SECRETOS CONFIGURADOS:" -ForegroundColor Cyan
Write-Host "   AZURE_CLIENT_ID = $AZURE_CLIENT_ID"
Write-Host "   AZURE_CLIENT_SECRET = [HIDDEN]"
Write-Host "   AZURE_SUBSCRIPTION_ID = $AZURE_SUBSCRIPTION_ID"
Write-Host "   AZURE_TENANT_ID = $AZURE_TENANT_ID"
Write-Host ""
Write-Host "🚀 PRÓXIMOS PASOS:" -ForegroundColor Yellow
Write-Host "1. Hacer commit y push de tus cambios"
Write-Host "2. Ir a GitHub Actions: https://github.com/JuanJojoa7/microservice-app-example/actions"
Write-Host "3. Ejecutar 'Infrastructure Pipeline'"
Write-Host "4. Seleccionar acción: 'deploy'"
Write-Host "5. ¡Disfrutar tu aplicación en Azure!"
Write-Host ""
Write-Host "💰 Costo estimado: ~`$7-10 USD/mes" -ForegroundColor Green
Write-Host "🗑️  Para eliminar: Ejecutar pipeline con acción 'destroy'" -ForegroundColor Yellow
Write-Host ""

# Limpiar archivo de credenciales
Remove-Item sp-credentials.json -ErrorAction SilentlyContinue

Read-Host "Presiona Enter para continuar..."