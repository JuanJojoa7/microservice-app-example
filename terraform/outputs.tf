# ============================================
# OUTPUTS ADICIONALES PARA DEBUGGING
# ============================================

output "resource_group_name" {
  description = "Nombre del grupo de recursos creado"
  value       = azurerm_resource_group.main.name
}

output "vm_name" {
  description = "Nombre de la máquina virtual"
  value       = azurerm_linux_virtual_machine.main.name
}

output "deployment_instructions" {
  description = "Instrucciones de uso"
  sensitive   = true
  value = <<-EOT
  
  🚀 DESPLIEGUE COMPLETADO
  
  📋 INFORMACIÓN DE ACCESO:
  • IP Pública: ${azurerm_public_ip.main.ip_address}
  • SSH: ssh ${var.admin_username}@${azurerm_public_ip.main.ip_address}
  • Contraseña: ${var.admin_password}
  
  🌐 APLICACIÓN:
  • App: http://${azurerm_public_ip.main.ip_address}
  • Dashboard: http://${azurerm_public_ip.main.ip_address}:8404/stats
  • Usuario app: admin / admin
  
  💻 COMANDOS ÚTILES EN LA VM:
  • Ver logs: sudo journalctl -f
  • Redesplegar: ./deploy-app.sh
  • Ver contenedores: docker ps
  • Logs de app: docker-compose -f docker-compose-simple.yml logs
  
  💰 COSTO ESTIMADO: ~$7-10 USD/mes
  
  EOT
}

output "cleanup_command" {
  description = "Comando para limpiar recursos"
  value       = "terraform destroy -auto-approve"
}