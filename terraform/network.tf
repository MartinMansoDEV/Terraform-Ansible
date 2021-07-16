# Creación de red
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network

resource "azurerm_virtual_network" "myNet" {
    name                = "kubernetesnet"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    tags = {
        environment = "CP2"
    }
}

# Creación de subnet
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet

resource "azurerm_subnet" "mySubnet" {
    name                   = "terraformsubnet"
    resource_group_name    = azurerm_resource_group.rg.name
    virtual_network_name   = azurerm_virtual_network.myNet.name
    address_prefixes       = ["10.0.1.0/24"]

}

# Create NIC
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface

resource "azurerm_network_interface" "myNic1" {

  count               = length(var.vms)
  name                = "interface-${var.vms[count.index].name}"  
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                           = "myipconfiguration-${var.vms[count.index].name}"
    subnet_id                      = azurerm_subnet.mySubnet.id 
    private_ip_address_allocation  = "Static"
    private_ip_address             = var.vms[count.index].ip
    public_ip_address_id           = element(azurerm_public_ip.myPublicIp.*.id, count.index)
  }

  tags = {
      environment = "CP2"
  }

}

# IP pública
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip

resource "azurerm_public_ip" "myPublicIp" {

  count               = length(var.vms) 
  name                = "vmip-${var.vms[count.index].name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.vms[count.index].name}-manand" 
  sku                 = "Basic"

  tags = {
      environment = "CP2"
  }

}

# Crea la zona para la DNS
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record

resource "azurerm_dns_zone" "myAzureZone" {
  count               = length(var.vms)
  name                = "${var.vms[count.index].name}.manand.lab"
  resource_group_name = azurerm_resource_group.rg.name
}

# Crea el registro A para la DNS
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record

resource "azurerm_dns_a_record" "myAzureDNS" {
  count               = length(var.vms) 
  name                = "record-${var.vms[count.index].name}"
  zone_name           = element(azurerm_dns_zone.myAzureZone.*.name, count.index)
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  target_resource_id  =  element(azurerm_public_ip.myPublicIp.*.id, count.index)
}