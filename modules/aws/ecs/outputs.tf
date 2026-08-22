output "cluster_id" { value = aws_ecs_cluster.cluster.id }
output "service_id" { value = aws_ecs_service.service.id }
output "task_definition_arn" { value = aws_ecs_task_definition.task.arn }
