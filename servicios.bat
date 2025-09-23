@echo off
chcp 65001 >nul

if "%1"=="start" goto start
if "%1"=="stop" goto stop
if "%1"=="status" goto status

echo Uso: servicios.bat [start|stop|status]
echo.
echo start  - Inicia todos los servicios
echo stop   - Para todos los servicios
echo status - Muestra estado de los servicios
echo.
goto end

:start
echo Iniciando servicios con patrones de nube...
docker-compose -f docker-compose-simple.yml up -d
echo.
echo Esperando que los servicios estén listos...
timeout /t 20 /nobreak >nul
echo.
echo ✓ Servicios iniciados. Accesos:
echo • Aplicación: http://localhost
echo • Dashboard: http://localhost:8404/stats
goto end

:stop
echo Deteniendo todos los servicios...
docker-compose -f docker-compose-simple.yml down
echo ✓ Servicios detenidos
goto end

:status
echo Estado actual de los servicios:
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo.
echo Probando conectividad:
powershell -Command "try { Write-Host 'App: ' -NoNewline; (Invoke-WebRequest -Uri http://localhost -UseBasicParsing).StatusCode } catch { Write-Host 'OFFLINE' -ForegroundColor Red }"
powershell -Command "try { Write-Host 'Dashboard: ' -NoNewline; (Invoke-WebRequest -Uri http://localhost:8404/stats -UseBasicParsing).StatusCode } catch { Write-Host 'OFFLINE' -ForegroundColor Red }"
goto end

:end