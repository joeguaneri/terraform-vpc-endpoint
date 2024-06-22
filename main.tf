variable "vpc_id" {
  type = string
}

variable "service_name" {
  type = string
}

variable "security_group_ids" {
  type = set(string)
}

variable "subnet_ids" {
  type = set(string)
}

variable "endpoint_type" {
  type = string
  default = "Interface"
}

resource aws_vpc_endpoint "vpce" {
  vpc_id              = var.vpc_id
  service_name        = var.service_name
  vpc_endpoint_type   = var.endpoint_type
  private_dns_enabled = var.endpoint_type == "Interface" ? true : null
  security_group_ids  = var.endpoint_type == "Interface" ? var.security_group_ids : null
}

resource aws_vpc_endpoint_subnet_association "sna" {
  for_each = var.endpoint_type == "Interface" ? var.subnet_ids : []

  vpc_endpoint_id = aws_vpc_endpoint.vpce.id
  subnet_id       = each.value
}

data aws_route_table "rts" {
  for_each = var.endpoint_type == "Interface" ?  [] : var.subnet_ids

  subnet_id = each.value
}

resource aws_vpc_endpoint_route_table_association "rta" {
  for_each = var.endpoint_type == "Interface" ?  [] : data.aws_route_table.rts

  route_table_id = each.value
  vpc_endpoint_id = aws_vpc_endpoint.vpce.id
}
