resource "aws_alb" "vault_alb" {
  name = "ALB-MAIN-VAULT"
  internal = false
  load_balancer_type = "application"
  security_groups = [var.alb_sg]        # must be always list
  subnets = var.public_subnet_ids

  enable_deletion_protection = false
  tags = {
    Name = "ALB_for_vault"
  }
}

resource "aws_lb_target_group" "vault_tg" {
  vpc_id = var.vpc_id
  name = "vault-target-group"
  port = 8200
  protocol = "HTTPS"
  
  health_check {
    enabled = true
    interval = 30
    path = "/v1/sys/health"
    protocol = "HTTPS"
    timeout = 10
    healthy_threshold = 3
    unhealthy_threshold = 3
  }

}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_alb.vault_alb.arn
  port = "443"
  protocol = "HTTPS"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.vault_tg.arn
  }

  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.certificate_arn_lb
}

resource "aws_lb_target_group_attachment" "vault_tg_attachment" {
  count = length(var.vault_nodes_ids)
  target_group_arn = aws_lb_target_group.vault_tg.arn
  target_id        = var.vault_nodes_ids[count.index]
  port             = 8200
}
