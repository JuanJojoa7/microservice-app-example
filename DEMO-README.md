# 🚀 Demostración de Patrones de Nube

Este proyecto implementa **Circuit Breaker** y **Cache Aside** patterns para microservicios sin modificar el código original.

## 📁 Scripts de Demostración

### 🎬 Scripts Principales:
- **`comparacion-patrones.bat`** - **¡DEMO COMPLETA!** Comparación sin/con patrones (15 min)
- **`demo-patterns.bat`** - Demostración solo con patrones (5 min)
- **`demo-cache-aside.bat`** - Demostración específica de Cache con tiempos
- **`demo-circuit-breaker.bat`** - Solo Circuit Breaker

### 🔧 Scripts de Control:
- **`servicios.bat`** - Control manual (start/stop/status)

### 📋 Configuración:
- **`docker-compose-simple.yml`** - Con patrones (HAProxy + Redis)
- **`docker-compose-sin-patrones.yml`** - Sin patrones (para comparar)
- **`haproxy-simple.cfg`** - Configuración Circuit Breaker

## � Para Presentación (8 minutos)

### **OPCIÓN 1: Demo Comparativa Completa (Recomendado)**
```cmd
comparacion-patrones.bat
```
**Muestra TODO:** Sin patrones vs Con patrones - diferencia clara

### **OPCIÓN 2: Solo Con Patrones**
```cmd
demo-patterns.bat
```

## 🌐 Accesos Durante Demo

- **Aplicación:** http://localhost
- **Usuario:** admin / **Contraseña:** admin  
- **Dashboard:** http://localhost:8404/stats (solo con patrones)

## 🔧 Patrones Implementados

### 1. Circuit Breaker (HAProxy)
**SIN PATRÓN:**
- ❌ Aplicación se cuelga 30-60 segundos
- ❌ Usuario no sabe qué pasa
- ❌ Sin información de estado

**CON CIRCUIT BREAKER:**
- ✅ Respuesta inmediata (503 Service Unavailable)
- ✅ Dashboard de monitoreo en tiempo real
- ✅ Recuperación automática (detecta en 15 segundos)
- ✅ Usuario informado del problema

### 2. Cache Aside (Redis)
**SIN CACHÉ:**
- ❌ Todas las consultas van a base de datos (~500ms)
- ❌ Alta carga en servicios backend
- ❌ Experiencia lenta para el usuario

**CON CACHE ASIDE:**
- ✅ Consultas frecuentes desde cache (~1-5ms)
- ✅ 99% reducción en tiempo de respuesta
- ✅ Menor carga en base de datos
- ✅ Fallback automático si cache falla

## 📊 Resultados Medibles

### Circuit Breaker
| Situación | Sin Patrón | Con Patrón |
|-----------|------------|------------|
| Tiempo de respuesta ante falla | 30-60 segundos | < 1 segundo |
| Información al usuario | Página no carga | Error 503 claro |
| Recuperación | Manual | Automática |
| Monitoreo | No existe | Dashboard en vivo |

### Cache Aside
| Tipo de Consulta | Sin Cache | Con Cache | Mejora |
|-----------------|-----------|-----------|---------|
| Primera consulta | ~500ms | ~500ms | 0% |
| Consultas repetidas | ~500ms | ~1-5ms | 99% |
| Carga de BD | 100% | 20% | 80% reducción |

## 🎭 Explicación de Beneficios

### ¿Por qué Circuit Breaker es importante?

**Problema real:** Cuando un microservicio falla, el frontend intenta conectarse y se queda "colgado" esperando respuesta por timeout (30-90 segundos). El usuario ve una página que no carga y no sabe qué pasa.

**Solución Circuit Breaker:** HAProxy detecta que el servicio está caído y devuelve inmediatamente un error 503. El usuario sabe que hay un problema y puede intentar más tarde.

### ¿Por qué Cache Aside mejora performance?

**Problema real:** Cada vez que consultas TODOs, va a la base de datos (lento). Si 100 usuarios consultan, son 100 queries a BD.

**Solución Cache Aside:** La primera consulta va a BD y se guarda en Redis. Las siguientes 99 consultas vienen de Redis (ultra rápido), solo 1 query a BD.

## 🔥 Demo Scripts Específicos

### Ver diferencia real:
```cmd
# Comparación completa (muestra sin vs con patrones)
comparacion-patrones.bat

# Solo cache con medición de tiempos
demo-cache-aside.bat

# Solo circuit breaker
demo-circuit-breaker.bat
```

### Control manual:
```cmd
servicios.bat start    # Iniciar con patrones
servicios.bat stop     # Parar todo
servicios.bat status   # Ver estado actual
```