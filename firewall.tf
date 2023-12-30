resource "aws_networkfirewall_firewall" "FW-myVPC" {
  name                = "NetworkFirewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.anfw_policy.arn
  vpc_id              = aws_vpc.inspection_vpc.id

  dynamic "subnet_mapping" {
    for_each = aws_subnet.inspection_vpc_firewall_subnet[*].id

    content {
      subnet_id = subnet_mapping.value
    }
  }
}

# Primero la politica 
resource "aws_networkfirewall_firewall_policy" "anfw_policy" {
  name = "firewall-policy"
  
  firewall_policy {
        stateless_default_actions          = ["aws:pass"]
        stateless_fragment_default_actions = ["aws:drop"]
}
}

#Grupo de reglas 
resource "aws_networkfirewall_rule_group" "drop_icmp" {
  capacity = 1
  name     = "drop-icmp"
  type     = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 1
          rule_definition {
            actions = ["aws:drop"]
            match_attributes {
              protocols = [1]
              source {
                address_definition = "0.0.0.0/0"
              }
              destination {
                address_definition = "0.0.0.0/0"
              }
            }
          }
        }
      }
    }
  }
}

