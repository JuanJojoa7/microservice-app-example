@echo off
chcp 65001 >nul
echo ================================================================
echo   🔧 CONFIGURACIÓN AUTOMÁTICA AZURE + GITHUB
echo   Obtener credenciales y configurar secretos
echo ================================================================
echo.

echo 📋 PASO 1: Verificando herramientas...

REM Verificar Azure CLI
echo 🔍 Verificando Azure CLI...
az --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Azure CLI no instalado
    echo.
    echo 💡 SOLUCIÓN:
    echo    1. Ejecutar: winget install Microsoft.AzureCLI
    echo    2. O descargar desde: https://aka.ms/InstallAzureCLI
    echo    3. Reiniciar PowerShell después de instalar
    echo.
    echo Presiona cualquier tecla después de instalar Azure CLI...
    pause
    exit /b 1
)
echo ✅ Azure CLI encontrado

REM Verificar GitHub CLI con rutas posibles
echo 🔍 Verificando GitHub CLI...
set "GH_CMD="

REM Intentar encontrar gh en rutas comunes
where gh >nul 2>&1 && set "GH_CMD=gh"
if not defined GH_CMD (
    if exist "C:\Program Files\GitHub CLI\gh.exe" set "GH_CMD=C:\Program Files\GitHub CLI\gh.exe"
)
if not defined GH_CMD (
    if exist "C:\Program Files (x86)\GitHub CLI\gh.exe" set "GH_CMD=C:\Program Files (x86)\GitHub CLI\gh.exe"
)
if not defined GH_CMD (
    if exist "%USERPROFILE%\AppData\Local\Programs\GitHub CLI\gh.exe" set "GH_CMD=%USERPROFILE%\AppData\Local\Programs\GitHub CLI\gh.exe"
)

if not defined GH_CMD (
    echo ❌ GitHub CLI no encontrado
    echo.
    echo 💡 SOLUCIÓN:
    echo    1. Ejecutar: winget install GitHub.cli
    echo    2. O descargar desde: https://cli.github.com/
    echo    3. CERRAR Y ABRIR PowerShell después de instalar
    echo.
    echo ¿Ya instalaste GitHub CLI? (Y/N)
    set /p respuesta=
    if /i "%respuesta%"=="Y" (
        echo.
        echo ⚠️  CIERRA PowerShell y ábrelo de nuevo, luego ejecuta:
        echo    .\setup-github-secrets.bat
        echo.
    )
    pause
    exit /b 1
)

echo ✅ GitHub CLI encontrado: %GH_CMD%
echo.

echo 📋 PASO 2: Verificando autenticación GitHub...
"%GH_CMD%" auth status >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ No estás autenticado en GitHub
    echo 🔐 Ejecutando autenticación...
    "%GH_CMD%" auth login
    if %errorlevel% neq 0 (
        echo ❌ Error en autenticación
        pause
        exit /b 1
    )
)
echo ✅ GitHub CLI autenticado

echo 📋 PASO 3: Login a Azure...
REM Verificar si ya está logueado
az account show >nul 2>&1
if %errorlevel% neq 0 (
    echo 🔐 Abriendo login de Azure...
    az login
    if %errorlevel% neq 0 (
        echo ❌ Error en login de Azure
        pause
        exit /b 1
    )
)

echo ✅ Login a Azure exitoso
echo.

echo 📋 PASO 3: Obteniendo información de Azure...

REM Obtener información de la suscripción
echo 📊 Obteniendo datos de suscripción...
for /f "delims=" %%i in ('az account show --query "id" -o tsv') do set AZURE_SUBSCRIPTION_ID=%%i
for /f "delims=" %%i in ('az account show --query "tenantId" -o tsv') do set AZURE_TENANT_ID=%%i

echo ✅ Subscription ID: %AZURE_SUBSCRIPTION_ID%
echo ✅ Tenant ID: %AZURE_TENANT_ID%
echo.

echo 📋 PASO 4: Creando Service Principal...

REM Generar nombre único
for /f "tokens=2 delims==." %%i in ('wmic os get localdatetime /format:list ^| find "="') do set datetime=%%i
set timestamp=%datetime:~0,14%
set SP_NAME=sp-microservices-%timestamp%

echo 🔧 Creando Service Principal: %SP_NAME%

REM Crear Service Principal y capturar JSON
az ad sp create-for-rbac --name "%SP_NAME%" --role "Contributor" --scopes "/subscriptions/%AZURE_SUBSCRIPTION_ID%" --sdk-auth > sp-credentials.json

if %errorlevel% neq 0 (
    echo ❌ Error creando Service Principal
    pause
    exit /b 1
)

echo ✅ Service Principal creado exitosamente
echo.

echo 📋 PASO 5: Extrayendo credenciales...

REM Extraer valores del JSON usando PowerShell
powershell -Command "$json = Get-Content 'sp-credentials.json' | ConvertFrom-Json; Write-Output $json.clientId" > temp_client_id.txt
powershell -Command "$json = Get-Content 'sp-credentials.json' | ConvertFrom-Json; Write-Output $json.clientSecret" > temp_client_secret.txt

set /p AZURE_CLIENT_ID=<temp_client_id.txt
set /p AZURE_CLIENT_SECRET=<temp_client_secret.txt

REM Limpiar archivos temporales
del temp_client_id.txt temp_client_secret.txt

echo ✅ Client ID: %AZURE_CLIENT_ID%
echo ✅ Client Secret: [HIDDEN]
echo.

echo 📋 PASO 6: Login a GitHub...

REM Verificar login a GitHub
"%GH_CMD%" auth status >nul 2>&1
if %errorlevel% neq 0 (
    echo 🔐 Login a GitHub requerido...
    "%GH_CMD%" auth login
    if %errorlevel% neq 0 (
        echo ❌ Error en login de GitHub
        pause
        exit /b 1
    )
)

echo ✅ Login a GitHub exitoso
echo.

echo 📋 PASO 7: Configurando secretos en GitHub...

REM Configurar secretos uno por uno
echo 🔧 Configurando AZURE_CLIENT_ID...
echo %AZURE_CLIENT_ID% | "%GH_CMD%" secret set AZURE_CLIENT_ID

echo 🔧 Configurando AZURE_CLIENT_SECRET...
echo %AZURE_CLIENT_SECRET% | "%GH_CMD%" secret set AZURE_CLIENT_SECRET

echo 🔧 Configurando AZURE_SUBSCRIPTION_ID...
echo %AZURE_SUBSCRIPTION_ID% | "%GH_CMD%" secret set AZURE_SUBSCRIPTION_ID

echo 🔧 Configurando AZURE_TENANT_ID...
echo %AZURE_TENANT_ID% | "%GH_CMD%" secret set AZURE_TENANT_ID

echo.
echo 📋 PASO 8: Verificando configuración...

REM Verificar que los secretos se configuraron
"%GH_CMD%" secret list | findstr AZURE >nul
if %errorlevel% neq 0 (
    echo ⚠️ No se pudieron verificar los secretos, pero deberían estar configurados
) else (
    echo ✅ Secretos verificados en GitHub
)

echo.
echo 🎉 ¡CONFIGURACIÓN COMPLETADA!
echo ================================
echo.
echo ✅ Service Principal creado: %SP_NAME%
echo ✅ Credenciales extraídas automáticamente
echo ✅ Secretos configurados en GitHub Repository
echo.
echo 📊 RESUMEN DE SECRETOS CONFIGURADOS:
echo    AZURE_CLIENT_ID = %AZURE_CLIENT_ID%
echo    AZURE_CLIENT_SECRET = [HIDDEN]
echo    AZURE_SUBSCRIPTION_ID = %AZURE_SUBSCRIPTION_ID%
echo    AZURE_TENANT_ID = %AZURE_TENANT_ID%
echo.
echo 🚀 PRÓXIMOS PASOS:
echo 1. Hacer commit y push de tus cambios
echo 2. Ir a GitHub Actions: https://github.com/JuanJojoa7/microservice-app-example/actions
echo 3. Ejecutar "Infrastructure Pipeline"
echo 4. Seleccionar acción: "deploy"
echo 5. ¡Disfrutar tu aplicación en Azure!
echo.
echo 💰 Costo estimado: ~$7-10 USD/mes
echo 🗑️  Para eliminar: Ejecutar pipeline con acción "destroy"
echo.

REM Limpiar archivo de credenciales
del sp-credentials.json 2>nul

pause