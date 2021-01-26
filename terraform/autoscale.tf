locals {
  resource_id = "service/${aws_ecs_cluster.default.name}/${aws_ecs_service.rails.name}"
}

resource "aws_iam_service_linked_role" "ecs_autoscale" {
  aws_service_name = "ecs.application-autoscaling.amazonaws.com"
}

resource "aws_appautoscaling_target" "ecs_target" {
  service_namespace  = "ecs"
  resource_id        = local.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = aws_iam_service_linked_role.ecs_autoscale.arn
  min_capacity       = var.ecs_auto_scale_min[terraform.workspace]
  max_capacity       = var.ecs_auto_scale_max[terraform.workspace]
}

# Automatically scale capacity up by one
resource "aws_appautoscaling_policy" "scale_up" {
  name               = "${var.app_name}-${terraform.workspace}-scale-up"
  service_namespace  = "ecs"
  resource_id        = local.resource_id
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 600
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.ecs_target]
}

# Automatically scale capacity down by one
resource "aws_appautoscaling_policy" "scale_down" {
  name               = "${var.app_name}-${terraform.workspace}-scale-down"
  service_namespace  = "ecs"
  resource_id        = local.resource_id
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 600
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.ecs_target]
}

# Cloudwatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.app_name}-${terraform.workspace}-cpu-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  namespace           = "ECS/ContainerInsights"
  metric_name         = "CpuUtilized"
  period              = 60
  statistic           = "Average"
  threshold           = 60

  dimensions = {
    ClusterName = aws_ecs_cluster.default.name
    ServiceName = aws_ecs_service.rails.name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_up.arn]
}

# Cloudwatch alarm that triggers the autoscaling down policy
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.app_name}-${terraform.workspace}-cpu-utilization-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CpuUtilized"
  namespace           = "ECS/ContainerInsights"
  period              = 60
  statistic           = "Average"
  threshold           = 30

  dimensions = {
    ClusterName = aws_ecs_cluster.default.name
    ServiceName = aws_ecs_service.rails.name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_down.arn]
}
