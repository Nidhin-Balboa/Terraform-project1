// to set the aws regions

variable "aws_region" {
  default = "eu-west-1"

}

variable "vpc_cidr_block" {

  description = "this value for providing the vpc cidr block"
  type = string
  default = "10.2.0.0/16"

}

variable "subnet_count" {
  description = "this value for the number of vpc subnet count"
  type = map(number)
  default = {
    public = 1,
    private = 2
 }


}

variable "settings" {

  description = "configuration settings"
  type        = map(any)
  default = {
    "database" = {
            allocated_storage = 10               //storage in
            engine            = "mysql"         //engine type
            engine_version    = "8.0.32"       //engine version
            instance_class    = "db.t3.micro"    //engine instance
            db_name           = "terraform"
            skip_final_snapshot = true
        },
        "web_app" = {
            count        =  1   //number of instaces
            instance_type  = "t3.medium"   // instnce type
        }

    }
}

variable "public_subnet_cidr_blocks" {
    description = "available public subnet cidr blocks"
    type        =  list(string)
    default = [
        "10.2.0.0/23",
        "10.2.2.0/23",
        "10.2.4.0/23",
        "10.2.6.0/23",
        "10.2.8.0/23"
    ]
}

variable "private_subnet_cidr_blocks" {
    description = "available private subnet cidr blocks  "
    type        =  list(string)
    default = [
        "10.2.10.0/23",
        "10.2.12.0/23",
        "10.2.14.0/23",
        "10.2.16.0/23",
        "10.2.18.0/23"
    ]
}

variable "my_ip" {
  description = "this elastic ip address"
  type        = string
  sensitive   = true

}

variable "db_username" {
  description = "database master user name"
  type        = string
  sensitive   = true

}

variable "db_password" {
  description = "database master password"
  type        = string
  sensitive   = true

}

