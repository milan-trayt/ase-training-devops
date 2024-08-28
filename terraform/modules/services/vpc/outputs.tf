output "vpc_id" {
  value = aws_vpc.main.id
}

output "cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "public_subnet" {
  value       = aws_subnet.public_subnet[*].id
  description = "list of public subnet ids"
}

output "private_subnet" {
  value       = aws_subnet.private_subnet[*].id
  description = "list of private subnet ids"
}

output "private_subnet_cidr" {
  value       = aws_subnet.private_subnet[*].cidr_block
  description = "list of private subnet cidrs"
}

output "private_database_subnet_ids" {
  value       = aws_subnet.private_database_subnet[*].id
  description = "list of private subnet ids where the database lives"
}

output "private_database_cidr_blocks" {
  value       = aws_subnet.private_database_subnet[*].cidr_block
  description = "the cidr blocks for the database"
}

output "private_routetable_id" {
  value = aws_route_table.private_route.id
}

output "public_routetable_id" {
  value = aws_route_table.public_route.id
}
