#Define Variables






#Define Variables
variable "prefix" {
    type        = string
    description = "variable prefix to append at beginning of names"
}

variable "az_reg" {
    type        = string 
    description = "local region"
}

variable "tags" {
    type = map(string)
}

variable "dns_servers" {
    type        = list(string)
    description = "DNS Servers to use"
}



variable "hub_routes_v4" {
    type = map(string)
}

variable "hub_routes_v6" {
    type = map(string)
}

/*
variable "hub_bastion_v4" {
    type = string
    description = "Bastion Subnet in Hub v4"
}

variable "hub_bastion_v6" {
    type = string
    description = "Bastion Subnet in Hub v6"
}
*/

variable "spoke_cidrs_v4" {
    type        = map(string)
    description = "Map of IPv4 spoke CIDRs for region"
}

variable "spoke_cidrs_v6" {
    type        = map(string)
    description = "Map of IPv6 spoke CIDRs for region"
}

variable "gw_ip_v4" {
    type        = string 
    description = "Default IPv4 GW IP in Hub"
}

variable "gw_ip_v6" {
    type        = string 
    description = "Default IPv6 GW IP in Hub"
}


variable "hub_id" {
    type        = string
    description = "ID of the local Hub"
}


variable "ExprRT_BGP_Primary_Community" {
    type        = string 
    description = "AS # of Primary"
    default     = "null"
}

variable "spoke_subnets" {
    description = "subnet definition variable"
    type = map(object({
        Subs                            = list(string)
        Sub_Svc_Endpoints               = list(string)
        Sub_Delegation                  = bool
        Sub_Delegation_Name             = string
        Sub_Delegation_Actions_Name     = string
        Sub_Delegation_Actions          = list(string)
        priv_endpt                      = string
        default_outbound_access_enabled = bool
        priv_link_net_pols              = bool
    }))
}


variable "spoke_peering_enabled" {
    type        = bool 
    description = "Variable that determines if peering should be enabled on spoke"
}



variable "er_bgp_primary_com" {
    type        = string 
    description = "BGP Community based on primary ER path"  
    default     = null
}














