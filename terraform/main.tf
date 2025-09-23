# ============================================
# AZURE TERRAFORM - CONFIGURACIÓN MÁS BARATA
# ============================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Variables para personalización
variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
  default     = "rg-microservices-demo"
}

variable "location" {
  description = "Región de Azure (permitida: East US 2)"
  type        = string
  default     = "East US 2"
}

variable "vm_size" {
  description = "Tamaño de VM (más barato: Standard_B1s)"
  type        = string
  default     = "Standard_B1s" # 1 vCPU, 1 GB RAM - MÁS BARATO
}

variable "admin_username" {
  description = "Usuario administrador"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Contraseña administrador"
  type        = string
  sensitive   = true
  default     = "MicroservicesDemo2025!"
}

# Grupo de recursos
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "demo"
    Project     = "microservices-patterns"
    Cost        = "minimal"
  }
}

# Red virtual
resource "azurerm_virtual_network" "main" {
  name                = "vnet-microservices"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = azurerm_resource_group.main.tags
}

# Subred
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# IP Pública
resource "azurerm_public_ip" "main" {
  name                = "pip-microservices-vm"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                 = "Basic" # Más barato que Standard

  tags = azurerm_resource_group.main.tags
}

# Grupo de seguridad de red
resource "azurerm_network_security_group" "main" {
  name                = "nsg-microservices-vm"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # SSH
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # HTTP
  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # HAProxy Stats
  security_rule {
    name                       = "HAProxy-Stats"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8404"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = azurerm_resource_group.main.tags
}

# Interfaz de red
resource "azurerm_network_interface" "main" {
  name                = "nic-microservices-vm"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }

  tags = azurerm_resource_group.main.tags
}

# Asociar grupo de seguridad a interfaz de red
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Disco del SO
resource "azurerm_managed_disk" "main" {
  name                 = "disk-microservices-vm-os"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS" # Más barato que Premium
  create_option        = "Empty"
  disk_size_gb         = 30 # Mínimo necesario

  tags = azurerm_resource_group.main.tags
}

# Máquina Virtual - MÁS BARATA POSIBLE
resource "azurerm_linux_virtual_machine" "main" {
  name                = "vm-microservices-demo"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = var.vm_size
  admin_username      = var.admin_username

  # Deshabilitar boot diagnostics para ahorrar
  boot_diagnostics {}

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" # Más barato
  }

  # Ubuntu 22.04 LTS - Gratis
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  admin_password = var.admin_password

  # Script de inicialización para instalar Docker y Git
  custom_data = base64encode(local.cloud_init_script)

  tags = azurerm_resource_group.main.tags
}

# Script de inicialización
locals {
  cloud_init_script = <<-EOF
#!/bin/bash

# Log de instalación
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Iniciando configuración de VM para microservicios..."

# Actualizar sistema
apt-get update -y
apt-get upgrade -y

# Instalar dependencias básicas
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    unzip

# Instalar Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Configurar Docker
systemctl start docker
systemctl enable docker
usermod -aG docker ${var.admin_username}

# Instalar Docker Compose standalone
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Crear directorio para la aplicación
mkdir -p /home/${var.admin_username}/microservices-app
chown ${var.admin_username}:${var.admin_username} /home/${var.admin_username}/microservices-app

# Crear script de despliegue automático
cat > /home/${var.admin_username}/deploy-app.sh << 'DEPLOY_SCRIPT'
#!/bin/bash
set -e

echo "🚀 Desplegando aplicación de microservicios..."

# Ir al directorio de la app
cd /home/${var.admin_username}/microservices-app

# Si existe repositorio, actualizarlo; si no, clonarlo
if [ -d ".git" ]; then
    echo "📦 Actualizando repositorio..."
    git pull origin feature/infrastructure-setup
else
    echo "📦 Clonando repositorio..."
    git clone https://github.com/JuanJojoa7/microservice-app-example.git .
    git checkout feature/infrastructure-setup
fi

# Dar permisos a los scripts
chmod +x *.bat 2>/dev/null || true

# Parar contenedores existentes
docker-compose -f docker-compose-simple.yml down 2>/dev/null || true

# Limpiar imágenes antiguas para ahorrar espacio
docker system prune -f

# Construir e iniciar aplicación
docker-compose -f docker-compose-simple.yml up -d --build

# Esperar a que se inicialicen
sleep 30

# Verificar estado
docker ps

echo "✅ Aplicación desplegada en:"
echo "🌐 Aplicación: http://$(curl -s ifconfig.me)"
echo "📊 Dashboard: http://$(curl -s ifconfig.me):8404/stats"
echo "👤 Usuario: admin / Contraseña: admin"

DEPLOY_SCRIPT

# Hacer ejecutable el script
chmod +x /home/${var.admin_username}/deploy-app.sh
chown ${var.admin_username}:${var.admin_username} /home/${var.admin_username}/deploy-app.sh

# Ejecutar despliegue inicial
su - ${var.admin_username} -c '/home/${var.admin_username}/deploy-app.sh'

echo "✅ VM configurada y aplicación desplegada"
EOF
}

# Outputs
output "public_ip_address" {
  description = "IP pública de la VM"
  value       = azurerm_public_ip.main.ip_address
}

output "ssh_connection_command" {
  description = "Comando para conectar por SSH"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.main.ip_address}"
}

output "application_url" {
  description = "URL de la aplicación"
  value       = "http://${azurerm_public_ip.main.ip_address}"
}

output "dashboard_url" {
  description = "URL del dashboard de monitoreo"
  value       = "http://${azurerm_public_ip.main.ip_address}:8404/stats"
}

output "vm_cost_estimate" {
  description = "Estimación de costo mensual USD (aproximado)"
  value       = "~$7-10 USD/mes (Standard_B1s en East US 2)"
}