



#-----------------------------------------------
# Resource Group
#---------------------------------------------------
#

# -- Spoke vNet RSG with all subnets in Hub vNet and UDRs

resource "azurerm_resource_group" "spoke_rsg" {
    name                    = "${var.prefix}_RSG"
    location                = var.az_reg
    tags                    = var.tags
}

# -- Defining the Spoke vNet

resource "azurerm_virtual_network" "this" {
    name                    = "${var.prefix}_vNet"
    address_space           = values(merge(var.spoke_cidrs_v4, var.spoke_cidrs_v6))
    location                = var.az_reg
    resource_group_name     = azurerm_resource_group.spoke_rsg.name
    dns_servers             = var.dns_servers
    tags                    = var.tags
    bgp_community           = var.er_bgp_primary_com
}

#---------------------------------------------------------
# Route Table
#-------------------------------------------------------------
#
resource "azurerm_route_table" "this" {
    name                            = "${var.prefix}_UDR"
    location                        = var.az_reg
    resource_group_name             = azurerm_resource_group.spoke_rsg.name
    bgp_route_propagation_enabled   = false
    tags                            = var.tags
}

#---------------------------------------------------------
# Routes
#-------------------------------------------------------------
#

resource "azurerm_route" "v4_default" {
    name                    = "v4_Default"
    resource_group_name     = azurerm_resource_group.spoke_rsg.name
    route_table_name        = azurerm_route_table.this.name
    address_prefix          = "0.0.0.0/0"
    next_hop_type           = "VirtualAppliance" 
    next_hop_in_ip_address  = var.gw_ip_v4
}

resource "azurerm_route" "v6_default" {
    name                    = "v6_Default"
    resource_group_name     = azurerm_resource_group.spoke_rsg.name
    route_table_name        = azurerm_route_table.this.name
    address_prefix          = "::/0"
    next_hop_type           = "VirtualAppliance" 
    next_hop_in_ip_address  = var.gw_ip_v6
}


resource "azurerm_route" "v4_hub_routes" {
  for_each = var.hub_routes_v4
    name                    = each.key
    resource_group_name     = azurerm_resource_group.spoke_rsg.name
    route_table_name        = azurerm_route_table.this.name
    address_prefix          = each.value
    next_hop_type           = "VirtualAppliance" 
    next_hop_in_ip_address  = var.gw_ip_v4
}

/*
resource "azurerm_route" "v6_hub_routes" {
  for_each = var.hub_routes_v6
    name                    = each.key
    resource_group_name     = azurerm_resource_group.spoke_rsg.name
    route_table_name        = azurerm_route_table.this.name
    address_prefix          = each.value
    next_hop_type           = "VirtualAppliance" 
    next_hop_in_ip_address  = var.gw_ip_v6
}
*/



/*

resource "azurerm_route" "v4_hub_bastion" {
  for_each = var.hub_routes_v4
    name                    = each.key
    resource_group_name     = azurerm_resource_group.spoke_rsg.name
    route_table_name        = azurerm_route_table.this.name
    address_prefix          = each.value
    next_hop_type           = "VnetLocal" 

}

*/







#---------------------------------------------------------
# Create Subnets
#-------------------------------------------------------------
#

resource "azurerm_subnet" "this" {
  for_each = var.spoke_subnets
    name                                            = each.key
    resource_group_name                             = azurerm_resource_group.spoke_rsg.name
    virtual_network_name                            = azurerm_virtual_network.this.name
    address_prefixes                                = each.value["Subs"] 
    service_endpoints                               = contains( each.value["Sub_Svc_Endpoints"], "null" ) ? null : each.value["Sub_Svc_Endpoints"]
    private_endpoint_network_policies               = each.value["priv_endpt"] 
    default_outbound_access_enabled                 = each.value["default_outbound_access_enabled"]  
    private_link_service_network_policies_enabled   = each.value["priv_link_net_pols"] 


    dynamic "delegation" {
        for_each = each.value["Sub_Delegation"] ? [1] : [] 
        content {
          name = each.value["Sub_Delegation_Name"]
          service_delegation {
            actions = each.value["Sub_Delegation_Actions"]
            name    = each.value["Sub_Delegation_Actions_Name"]
          }
        }
     }
}

#---------------------------------------------------------
# Associate Route Tables to subnets
#-------------------------------------------------------------
#

resource "azurerm_subnet_route_table_association" "this" {
  for_each = var.spoke_subnets  
    subnet_id      = azurerm_subnet.this[each.key].id
    route_table_id = azurerm_route_table.this.id
}




resource "azurerm_virtual_network_peering" "spoke_to_hub" {
    count = var.spoke_peering_enabled ? 1 : 0
    name                          = "${var.prefix}_to_Hub"
    resource_group_name           = azurerm_resource_group.spoke_rsg.name
    virtual_network_name          = azurerm_virtual_network.this.name
    remote_virtual_network_id     = var.hub_id
    allow_virtual_network_access  = true
    allow_forwarded_traffic       = true
    use_remote_gateways           = true
}




