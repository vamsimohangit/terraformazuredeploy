# Configure the Azure Provider
provider "azurerm" {
  subscription_id = var.azure-subscription-id
  client_id       = var.azure-client-id
  client_secret   = var.azure-client-secret
  tenant_id       = var.azure-tenant-id
  version         = "=2.0.0"
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "example_rg" {
  name     = "${var.resource_prefix}-RG"
  location = var.node_location
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "example_vnet" {
  name                = "${var.resource_prefix}-vnet"
  resource_group_name = azurerm_resource_group.example_rg.name
  location            = var.node_location
  address_space       = var.node_address_space
}

# Create a subnets within the virtual network
resource "azurerm_subnet" "example_subnet" {
  name                 = "${var.resource_prefix}-subnet"
  resource_group_name  = azurerm_resource_group.example_rg.name
  virtual_network_name = azurerm_virtual_network.example_vnet.name
  address_prefix       = var.node_address_prefix
}

# Create Windiows Public IP
resource "azurerm_public_ip" "example_public_ip" {
  count               = var.node_count
  name                = "${var.resource_prefix}-${format("%02d", count.index)}-PublicIP"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name
  allocation_method   = var.Environment == "Test" ? "Static" : "Dynamic"
  domain_name_label = "testip-dns"
  tags = {
    environment = "Test"
  }
}
#Create DNS for VM
# azurerm_dns_cname_record "dnsrecord" {
  #name                = "${var.dns_name}"
  #zone_name           = "${data.azurerm_dns_zone.dnszone.name}"
  #resource_group_name = azurerm_resource_group.example_rg.name
  #ttl                 = "300"
  #record              = "${azurerm_public_ip.example_public_ip.fqdn}"
#}

# Create Network Interface
resource "azurerm_network_interface" "example_nic" {
  count               = var.node_count
  name                = "${var.resource_prefix}-${format("%02d", count.index)}-NIC"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name
  #
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.example_public_ip.*.id, count.index)
  }
}
# Creating resource NSG
resource "azurerm_network_security_group" "example_nsg" {
  name                = "${var.resource_prefix}-NSG"
  location            = azurerm_resource_group.example_rg.location
  resource_group_name = azurerm_resource_group.example_rg.name
  # Security rule can also be defined with resource azurerm_network_security_rule, here just defining it inline.
  security_rule {
    name                       = "Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = {
    environment = "Test"
  }
}

# Subnet and NSG association
resource "azurerm_subnet_network_security_group_association" "example_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.example_subnet.id
  network_security_group_id = azurerm_network_security_group.example_nsg.id
}

# Virtual Machine Creation — Windows
resource "azurerm_virtual_machine" "example_windows_vm" {
  count = var.node_count
  name  = "${var.resource_prefix}-${format("%02d", count.index)}"
  #name = "${var.resource_prefix}-VM"
  location              = azurerm_resource_group.example_rg.location
  resource_group_name   = azurerm_resource_group.example_rg.name
  network_interface_ids = [element(azurerm_network_interface.example_nic.*.id, count.index)]
  vm_size               = var.vm_instancesize

  storage_image_reference {
    publisher = "${element(split("/", var.vm_image), 0)}"
    offer     = "${element(split("/", var.vm_image), 1)}"
    sku       = "${element(split("/", var.vm_image), 2)}"
    version   = "${element(split("/", var.vm_image), 3)}"
  }
  storage_os_disk {
    name              = "myosdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.instance_name
    admin_username = var.vm_username
    admin_password = var.vm_password
  }
  os_profile_windows_config {
  }
  tags = {
    environment = "Test"
  }
}

#Create SQL server
resource "azurerm_sql_server" "example_sql_server" {
  name                         = var.sqlservername
  resource_group_name          = azurerm_resource_group.example_rg.name
  location                     = azurerm_resource_group.example_rg.location
  version                      = "12.0"
  administrator_login          = var.sqladmin
  administrator_login_password = var.sqlpassword
}