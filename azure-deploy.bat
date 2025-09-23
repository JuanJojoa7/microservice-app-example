@echo off
chcp 65001 >nul
echo ================================================================
echo   🚀 AZURE DEPLOYMENT HELPER
echo   Terraform + GitHub Actions
echo ================================================================
echo.

if "%1"=="init" goto init
if "%1"=="plan" goto plan  
if "%1"=="deploy" goto deploy
if "%1"=="destroy" goto destroy
if "%1"=="status" goto status

echo Uso: azure-deploy.bat [comando]
echo.
echo Comandos disponibles:
echo   init     - Configurar Terraform por primera vez
echo   plan     - Ver qué se va a crear (sin aplicar)
echo   deploy   - Desplegar infraestructura
echo   destroy  - Eliminar todo (ahorra dinero)
echo   status   - Ver estado actual
echo.
echo 💡 TIP: Para usar GitHub Actions, ve a:
echo    https://github.com/JuanJojoa7/microservice-app-example/actions
echo.
goto end

:init
echo 🔧 Inicializando Terraform...
cd terraform
terraform init
echo.
echo ✅ Terraform inicializado
echo 💡 Siguiente paso: azure-deploy.bat plan
goto end

:plan
echo 📋 Generando plan de Terraform...
cd terraform
terraform plan
echo.
echo 💡 Para aplicar: azure-deploy.bat deploy
goto end

:deploy
echo 🚀 Desplegando infraestructura...
echo ⚠️  Esto va a crear recursos en Azure (costo ~$7-10/mes)
echo.
set /p confirm="¿Continuar? (y/N): "
if /i not "%confirm%"=="y" goto end

cd terraform
terraform apply -auto-approve

echo.
echo 🎉 ¡Despliegue completado!
echo.
echo 📋 Para obtener información de acceso:
azure-deploy.bat status
goto end

:destroy
echo 💥 Eliminando infraestructura...
echo ⚠️  Esto va a ELIMINAR todos los recursos de Azure
echo.
set /p confirm="¿Estás seguro? (y/N): "
if /i not "%confirm%"=="y" goto end

cd terraform
terraform destroy -auto-approve

echo.
echo ✅ Infraestructura eliminada
echo 💰 Ya no hay costos en Azure
goto end

:status
echo 📊 Estado actual de la infraestructura...
cd terraform

if not exist "terraform.tfstate" (
    echo ❌ No hay infraestructura desplegada
    echo 💡 Para desplegar: azure-deploy.bat deploy
    goto end
)

echo.
echo 🌐 URLs de acceso:
terraform output application_url 2>nul || echo "❌ Error obteniendo URL"
terraform output dashboard_url 2>nul || echo "❌ Error obteniendo Dashboard"

echo.
echo 🔐 Comando SSH:
terraform output ssh_connection_command 2>nul || echo "❌ Error obteniendo SSH"

echo.
echo 💰 Costo estimado:
terraform output vm_cost_estimate 2>nul || echo "~$7-10 USD/mes"

goto end

:end
echo.