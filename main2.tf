provider "azurerm" {
  version = "2.2.0"
  features {}
}

resource "azurerm_resource_group" "vm_server_rg" {
  name     = "${var.vm_server_rg}-${var.vm_server_location[index]}"
  location = "${var.vm_server_rg}"
}

resource "azurerm_virtual_network" "vm_server_vnet" {
  name                = "${var.resource_prefix}-vnet"
  location            = "${var.vm_server_location}"
  resource_group_name = "${azurerm_resource_group.vm_server_rg.name}"
  address_space       = "{var.vm_server_address_space}"
}

resource "azurerm_subnet" "vm_server_subnet" {
  name                 = "${var.resource_prefix}-subnet"  
  resource_group_name  = "${azurerm_resource_group.vm_server_rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vm_server_vnet.name}"
  address_prefix       = "${var.vm_server_address_prefix}"
}

resource "azurerm_network_interface" "vm_server_nic" {
  name                = "${var.vm_server_name}-nic"  
  location            = var.vm_server_location
  resource_group_name = azurerm_resource_group.vm_server_rg.name

  ip_configuration {
     name                          = "${var.vm_server_name}-ip"
     subnet_id                     = azurerm_subnet.vm_server_subnet.id
     private_ip_address_allocation = "dynamic"
     public_ip_address_id          = azurerm_public_ip.vm_server_public_ip.id
  }
}

resource "azurerm_public_ip" "vm_server_public_ip" {
  name                = "${var.resource_prefix}-public-ip"
  location            = var.vm_server_location  
  resource_group_name = azurerm_resource_group.vm_server_rg.name  
  allocation_method   = var.environment == "newyork" ? "Static" : "Dynamic"
}

resource "azurerm_network_security_group" "vm_server_nsg" {
  name                = "${var.resource_prefix}-nsg"
  location            = var.vm_server_location  
  resource_group_name = azurerm_resource_group.vm_server_rg.name    
}

resource "azurerm_network_security_rule" "vm_server_nsg_rule_rdp" {
  name                        = "RDP Inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.vm_server_rg.name   
  network_security_group_name = azurerm_network_security_group.vm_server_nsg.name
}

resource "azurerm_network_interface_security_group_association" "vm_server_nsg_association" {
  network_security_group_id = azurerm_network_security_group.vm_server_nsg.id  
  network_interface_id      = azurerm_network_interface.vm_server_nic.id
}

resource "azurerm_windows_virtual_machine" "vm_server" {
  name                  = var.vm_server_name
  location              = var.vm_server_location  
  resource_group_name   = azurerm_resource_group.vm_server_rg.name  
  network_interface_ids = [azurerm_network_interface.vm_server_nic.id]
  size                  = "Standard_B1s"
  admin_username        = "vm-admin"
  admin_password        = "Passw0rd1234"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServerSemiAnnual"
    sku       = "Datacenter-Core-1709-smalldisk"
    version   = "latest"
  }

}