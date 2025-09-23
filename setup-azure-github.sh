#!/bin/bash

# ============================================
# CONFIGURACIÓN AUTOMÁTICA DE AZURE + GITHUB
# ============================================

set -e

echo "🔧 CONFIGURACIÓN INICIAL AZURE + GITHUB ACTIONS"
echo "================================================"
echo

# Verificar herramientas necesarias
command -v az >/dev/null 2>&1 || { echo "❌ Azure CLI no instalado. Instalar desde: https://aka.ms/InstallAzureCLI"; exit 1; }
command -v gh >/dev/null 2>&1 || { echo "❌ GitHub CLI no instalado. Instalar desde: https://cli.github.com/"; exit 1; }

echo "✅ Herramientas verificadas"
echo

# Login a Azure
echo "🔐 Login a Azure..."
if ! az account show >/dev/null 2>&1; then
    az login
fi

# Obtener información de la suscripción
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)

echo "📋 Información de Azure:"
echo "   Subscription: $SUBSCRIPTION_ID"
echo "   Tenant: $TENANT_ID"
echo

# Crear Service Principal
echo "🔧 Creando Service Principal..."
SP_NAME="sp-microservices-terraform-$(date +%s)"

CREDENTIALS=$(az ad sp create-for-rbac \
  --name "$SP_NAME" \
  --role "Contributor" \
  --scopes "/subscriptions/$SUBSCRIPTION_ID" \
  --sdk-auth)

echo "✅ Service Principal creado: $SP_NAME"
echo

# Login a GitHub
echo "🔐 Login a GitHub..."
if ! gh auth status >/dev/null 2>&1; then
    gh auth login
fi

# Configurar secreto en GitHub
echo "🔧 Configurando secreto AZURE_CREDENTIALS en GitHub..."
echo "$CREDENTIALS" | gh secret set AZURE_CREDENTIALS

echo "✅ Secreto configurado en GitHub"
echo

# Mostrar resumen
echo "🎉 CONFIGURACIÓN COMPLETADA"
echo "=========================="
echo
echo "✅ Service Principal creado en Azure"
echo "✅ Secreto AZURE_CREDENTIALS configurado en GitHub"
echo "✅ Listo para ejecutar pipelines"
echo
echo "🚀 PRÓXIMOS PASOS:"
echo "1. Ve a GitHub Actions: https://github.com/$(gh repo view --json owner,name -q '.owner.login + "/" + .name')/actions"
echo "2. Ejecuta 'Infrastructure Pipeline'"
echo "3. Selecciona acción: 'deploy'"
echo "4. ¡Disfruta tu infraestructura automática!"
echo
echo "💰 Costo estimado: ~$7-10 USD/mes"
echo "🗑️  Para eliminar: Ejecuta pipeline con acción 'destroy'"