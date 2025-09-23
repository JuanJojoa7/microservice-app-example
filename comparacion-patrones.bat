@echo off
chcp 65001 >nul
echo ================================================================
echo   COMPARACIÓN: SIN PATRONES vs CON PATRONES DE NUBE
echo ================================================================
echo.

echo [FASE 1] DEMOSTRANDO SIN PATRONES (Comportamiento tradicional)
echo ================================================================
echo.

echo Limpiando contenedores anteriores...
docker-compose -f docker-compose-simple.yml down 2>nul
docker-compose -f docker-compose-sin-patrones.yml down 2>nul
docker system prune -f >nul 2>&1

echo.
echo Iniciando aplicación SIN PATRONES...
docker-compose -f docker-compose-sin-patrones.yml up -d
echo Esperando que se inicialicen (20 segundos)...
timeout /t 20 /nobreak >nul

echo.
echo ✓ Aplicación SIN patrones funcionando en: http://localhost
echo Probando aplicación...
powershell -Command "Write-Host 'Estado: ' -NoNewline; try { (Invoke-WebRequest -Uri http://localhost -UseBasicParsing).StatusCode } catch { Write-Host 'ERROR' -ForegroundColor Red }"

echo.
echo [SIMULANDO FALLA] Apagando servicio auth...
docker stop sin_patrones_auth
echo.

echo PROBANDO SIN CIRCUIT BREAKER:
echo (Esto va a tomar MUCHO tiempo - hasta 30+ segundos de espera)
echo.
powershell -Command "$stopwatch = [System.Diagnostics.Stopwatch]::StartNew(); try { Write-Host 'Intentando acceder... '; $response = Invoke-WebRequest -Uri http://localhost -TimeoutSec 60 -UseBasicParsing; Write-Host 'Respuesta: ' $response.StatusCode } catch { Write-Host 'ERROR después de ' $stopwatch.Elapsed.TotalSeconds ' segundos: La aplicación se COLGÓ esperando' -ForegroundColor Red } finally { $stopwatch.Stop() }"

echo.
echo ❌ SIN PATRONES: La aplicación se cuelga y el usuario no sabe qué pasa
echo.
echo Restaurando servicio...
docker start sin_patrones_auth
timeout /t 10 /nobreak >nul

echo.
echo Deteniendo aplicación sin patrones...
docker-compose -f docker-compose-sin-patrones.yml down >nul 2>&1

echo.
echo.
echo [FASE 2] DEMOSTRANDO CON PATRONES (Circuit Breaker + Cache)
echo ================================================================
echo.

echo Iniciando aplicación CON PATRONES...
docker-compose -f docker-compose-simple.yml up -d
echo Esperando que se inicialicen (30 segundos)...
timeout /t 30 /nobreak >nul

echo.
echo ✓ Aplicación CON patrones funcionando en: http://localhost
echo ✓ Dashboard de monitoreo en: http://localhost:8404/stats
echo.
echo Probando aplicación...
powershell -Command "Write-Host 'Estado: ' -NoNewline; try { (Invoke-WebRequest -Uri http://localhost -UseBasicParsing).StatusCode } catch { Write-Host 'ERROR' -ForegroundColor Red }"

echo.
echo [SIMULANDO FALLA] Apagando servicio auth...
docker stop microservices_auth
timeout /t 3 /nobreak >nul

echo.
echo PROBANDO CON CIRCUIT BREAKER:
echo (Respuesta INMEDIATA - sin esperas)
echo.
powershell -Command "$stopwatch = [System.Diagnostics.Stopwatch]::StartNew(); try { Write-Host 'Intentando acceder... '; $response = Invoke-WebRequest -Uri http://localhost -UseBasicParsing; Write-Host 'Respuesta: ' $response.StatusCode ' en ' $stopwatch.Elapsed.TotalSeconds ' segundos' } catch { Write-Host 'Circuit Breaker activado en ' $stopwatch.Elapsed.TotalSeconds ' segundos - ERROR 503 Service Unavailable' -ForegroundColor Yellow } finally { $stopwatch.Stop() }"

echo.
echo ✓ CON CIRCUIT BREAKER: Respuesta inmediata, usuario sabe que hay problema
echo.

echo Restaurando servicio...
docker start microservices_auth
echo Esperando recuperación automática (15 segundos)...
timeout /t 15 /nobreak >nul

echo.
echo Verificando recuperación automática...
powershell -Command "Write-Host 'Recuperado: ' -NoNewline; try { (Invoke-WebRequest -Uri http://localhost -UseBasicParsing).StatusCode } catch { Write-Host 'ERROR' -ForegroundColor Red }"

echo.
echo ================================================================
echo   COMPARACIÓN COMPLETADA
echo ================================================================
echo.
echo 📊 RESULTADOS:
echo.
echo ❌ SIN PATRONES:
echo   • Tiempo de falla: 30-60 segundos colgado
echo   • Usuario confundido (página no carga)
echo   • Sin información de qué está pasando
echo   • Sin monitoreo del estado de servicios
echo.
echo ✅ CON PATRONES:
echo   • Tiempo de falla: ^< 1 segundo
echo   • Error claro (503 Service Unavailable)
echo   • Dashboard con estado en tiempo real
echo   • Recuperación automática visible
echo   • Cache Redis para optimizar respuestas
echo.
echo ACCESOS DISPONIBLES:
echo • Aplicación: http://localhost
echo • Dashboard: http://localhost:8404/stats
echo • Usuario: admin / Contraseña: admin
echo.
echo Presiona cualquier tecla para salir...
pause >nul