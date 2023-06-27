# Locals are used for values that are repeated a lot in the configuration file. For Azure it could 
# be used to specify values like resource group or region.
# They are not passed in at runtime. Mainly used to keep your code DRY.


locals {
  region = "us-east-1"
  resource_group = "devops"
}