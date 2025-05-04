# RDS Subnet Group 생성
resource "aws_db_subnet_group" "db-subnet-group" {
  name = "three-tier-db-subnet-group"
  subnet_ids = data.terraform_remote_state.eks.outputs.private_subnets
}

resource "aws_security_group" "rds-sg" {
  name        = "project_rds-sg"
  vpc_id      = data.terraform_remote_state.eks.outputs.vpc_id

  tags = {
    Name = "project_rds-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_traffic_rds_1" {
  security_group_id = aws_security_group.rds-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3306
  to_port           = 3306
  ip_protocol       = "TCP"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_rds" {
  security_group_id = aws_security_group.rds-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_db_instance" "my_rds" {
  engine                 = "mysql"
  engine_version         = "8.0.40"
  instance_class         = "db.t4g.micro"  # 프리 티어 지원 인스턴스
  allocated_storage      = 20             # 최소 20GB (프리 티어 제한)
  db_name               = "wordpress"    # 데이터베이스 이름
  username              = "admin"         # RDS 사용자 이름
  password              = "wwoo3312" # RDS 비밀번호 (최소 8자)
  parameter_group_name  = "default.mysql8.0"

  publicly_accessible   = false   # 보안 강화를 위해 외부에서 접근 불가능하도록 설정
  skip_final_snapshot   = true    # 삭제 시 스냅샷 생성하지 않음 (테스트 환경)

  vpc_security_group_ids = [aws_security_group.rds-sg.id] # 보안 그룹 연결
  db_subnet_group_name   = aws_db_subnet_group.db-subnet-group.name # 서브넷 그룹
}

output "rds_ednpoint" {
  value = aws_db_instance.my_rds.endpoint
}