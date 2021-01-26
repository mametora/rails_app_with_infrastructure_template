resource "aws_sns_topic" "cloudwatch_topic" {
  name = "${var.app_name}-${terraform.workspace}-cloudwatch-topic"
}

# NOTE: subscribeはAWSコンソールから登録

resource "aws_cloudwatch_metric_alarm" "rails_cpu_high" {
  alarm_name          = "${var.app_name}-${terraform.workspace}-rails-cpu-high"
  namespace           = "ECS/ContainerInsights"
  metric_name         = "CpuUtilized"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 10
  period              = 60
  statistic           = "Average"
  threshold           = 90

  dimensions = {
    ClusterName = aws_ecs_cluster.default.name
    ServiceName = aws_ecs_service.rails.name
  }

  alarm_actions = [aws_sns_topic.cloudwatch_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "rails_memory_high" {
  alarm_name          = "${var.app_name}-${terraform.workspace}-rails-memory-high"
  namespace           = "ECS/ContainerInsights"
  metric_name         = "MemoryUtilized"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 10
  period              = 60
  statistic           = "Average"
  threshold           = 400

  dimensions = {
    ClusterName = aws_ecs_cluster.default.name
    ServiceName = aws_ecs_service.rails.name
  }

  alarm_actions = [aws_sns_topic.cloudwatch_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "rails_task_running_count_check" {
  alarm_name          = "${var.app_name}-${terraform.workspace}-rails-task-running-count"
  namespace           = "ECS/ContainerInsights"
  metric_name         = "RunningTaskCount"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  period              = 60
  statistic           = "Average"
  threshold           = 1

  dimensions = {
    ClusterName = aws_ecs_cluster.default.name
    ServiceName = aws_ecs_service.rails.name
  }

  alarm_actions = [aws_sns_topic.cloudwatch_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "rails_healthyhosts" {
  alarm_name          = "${var.app_name}-${terraform.workspace}-rails-healthyhosts"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HealthyHostCount"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_actions       = [aws_sns_topic.cloudwatch_topic.arn]
  dimensions          = {
    TargetGroup  = aws_lb_target_group.rails.arn_suffix
    LoadBalancer = aws_alb.default.arn_suffix
  }
}

resource "aws_cloudwatch_metric_alarm" "sidekiq_cpu_high" {
  alarm_name          = "${var.app_name}-${terraform.workspace}-sidekiq-cpu-high"
  namespace           = "ECS/ContainerInsights"
  metric_name         = "CpuUtilized"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 10
  period              = 60
  statistic           = "Average"
  threshold           = 90

  dimensions = {
    ClusterName = aws_ecs_cluster.default.name
    ServiceName = aws_ecs_service.sidekiq.name
  }

  alarm_actions = [aws_sns_topic.cloudwatch_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "sidekiq_memory_high" {
  alarm_name          = "${var.app_name}-${terraform.workspace}-sidekiq-memory-high"
  namespace           = "ECS/ContainerInsights"
  metric_name         = "MemoryUtilized"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 10
  period              = 60
  statistic           = "Average"
  threshold           = 400

  dimensions = {
    ClusterName = aws_ecs_cluster.default.name
    ServiceName = aws_ecs_service.sidekiq.name
  }

  alarm_actions = [aws_sns_topic.cloudwatch_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "sidekiq_task_running_count_check" {
  alarm_name          = "${var.app_name}-${terraform.workspace}-sidekiq-task-running-count"
  namespace           = "ECS/ContainerInsights"
  metric_name         = "RunningTaskCount"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  period              = 60
  statistic           = "Average"
  threshold           = 1

  dimensions = {
    ClusterName = aws_ecs_cluster.default.name
    ServiceName = aws_ecs_service.sidekiq.name
  }

  alarm_actions = [aws_sns_topic.cloudwatch_topic.arn]
}
