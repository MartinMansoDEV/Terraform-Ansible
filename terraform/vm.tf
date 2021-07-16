# Creamos una máquina virtual
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine

resource "azurerm_linux_virtual_machine" "myVMS"{

    count               = length(var.vms)
    name                = var.vms[count.index].name
    computer_name       = "${var.vms[count.index].name}.westeurope.cloudapp.azure.com"  # Establezco el hostname para la maquina, utilizado en ansible
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    size                = var.vms[count.index].size # Establezco el tamaño de las maquinas
    admin_username      = var.ssh_user
    network_interface_ids = [ element(azurerm_network_interface.myNic1.*.id, count.index) ]
    disable_password_authentication = true

    admin_ssh_key {
        username   = var.ssh_user
        public_key = file(var.public_key_path)
    }

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    plan {
        name      = "centos-8-stream-free"
        product   = "centos-8-stream-free"
        publisher = "cognosys"
    }

    source_image_reference {
        publisher = "cognosys"
        offer     = "centos-8-stream-free"
        sku       = "centos-8-stream-free"
        version   = "1.2019.0810"
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.stAccount.primary_blob_endpoint
    }

    tags = {
        environment = "CP2"
    }

    # Exporta a un fichero las ips generadas en el deploy, para que no haga falta ir al
    # proveedor para obtenerlas y modificar el archivo hosts de ansible.
    provisioner "local-exec" {
        command = "echo ${self.name} - ${self.public_ip_address} >> public_ip_address.txt"
    }

}