# print web-server ip
output "web_ip" {
  value = aws_instance.web_server.public_ip
}
# print app-server ip
output "app_ip" {
  value = aws_instance.app_server
}
# print db-server ip
output "db_ip" {
  value = aws_instance.db_server
}