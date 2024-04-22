resource "aws_ecs_cluster" "dreamkast_stg" {
  name = var.prj_prefix

  #tags = {
  #  Environment = "${var.prj_prefix}"
  #}
}
