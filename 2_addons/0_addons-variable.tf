variable "aws_region" {
  type = string
  default = "ap-northeast-2"
}

variable "cluster_name" {
  default = "myeks"
}



data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}
