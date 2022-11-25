resource "aws_vpc_endpoint" "s3" {
  vpc_id              = var.vpc_id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
}
resource "aws_vpc_endpoint_route_table_association" "s3" {
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = var.route_table_id
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.subned_public_1a_id,  var.subned_public_1c_id]
  security_group_ids  = [var.vpc_endpoint_sg_id]
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.subned_public_1a_id,  var.subned_public_1c_id]
  security_group_ids  = [var.vpc_endpoint_sg_id]
}