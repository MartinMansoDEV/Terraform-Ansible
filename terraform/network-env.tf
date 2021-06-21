
# Creación de subnet para distomtos entornos, esto genera diferentes redes.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet

resource "azurerm_subnet" "mySubnetEnv" {
    count = length(var.envs)
    name                   = "terraformsubnet-${var.envs[count.index]}"
    resource_group_name    = azurerm_resource_group.rg.name
    virtual_network_name   = azurerm_virtual_network.myNet.name
    address_prefixes       = ["10.0.${100 + count.index}.0/24"]

}

