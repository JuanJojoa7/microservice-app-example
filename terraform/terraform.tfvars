# ============================================
# VARIABLES DE TERRAFORM - PERSONALIZACIÓN
# ============================================

# Configuración del grupo de recursos
resource_group_name = "rg-microservices-demo"
location           = "East US"  # Región más barata

# Configuración de la VM (MÁS BARATA)
vm_size = "Standard_B1s"  # 1 vCPU, 1 GB RAM - ~$7-10/mes

# Credenciales de acceso
admin_username = "azureuser"
admin_password = "MicroservicesDemo2025!"  # Cambiar por una más segura

# IMPORTANTE: 
# - Esta configuración es la MÁS BARATA posible en Azure
# - Costo estimado: $7-10 USD/mes
# - Para producción, usar vm_size más grande