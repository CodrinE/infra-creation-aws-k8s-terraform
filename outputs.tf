output "public_ip" {
    description = "The public IP address assigned to the instance"
    value = try(aws_instance.web.public_ip, "")
}

output "private_ip" {
    description = "The private IP address assigned to the instance"
    value = try(aws_instance.web.private_ip, "")
}

output "tags_all" {
    description = "A map of tags assigned to the resource"
    value = try(aws_instance.web.tags_all, {})
}