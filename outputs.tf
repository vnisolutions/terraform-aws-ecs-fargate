output "ecs_cluster_name" {
  value = [aws_ecs_cluster.aws-ecs-cluster.name]
}

output "ecs_service_name" {
  value = [aws_ecs_service.aws-ecs-service.name]
}

output "sg_fargate" {
  value = [aws_security_group.sg-fargate.id]
}
