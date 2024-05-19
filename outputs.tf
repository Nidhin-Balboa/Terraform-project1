output "web_public_ip" {
    description = "the public ip address of the the webserver"
    value = aws_eip.terraform_web_eip[0].public_ip
  // need to check the output file

  depends_on = [ aws_eip.terraform_web_eip ]
}

output "web_public_dns" {
    description = "The publc DNS address of the webserver"
    value = aws_eip.terraform_web_eip[0].public_dns

    depends_on = [ aws_eip.terraform_web_eip ]


}

output "database_endpoint" {
    description = "The end point of database"
    value = aws_db_instance.terraform_rds.address


}


output "database_port" {
    description = "The port of the database"
    value = aws_db_instance.terraform_rds.port


}

