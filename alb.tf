# define ALB
resource "aws_alb" "alb" {
  name            = "${var.name_prefix}-alb"
  subnets         = aws_subnet.public_subnet.*.id
  security_groups = [aws_security_group.load_balancer_sg.id]
}

resource "aws_alb_target_group" "alb_target_group" {
  name        = "${var.name_prefix}-alb-target-group"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main_network.id
  target_type = "ip"
}

resource "aws_lb_listener" "redirect_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "load_balancer_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate_validation.devpod.certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.alb_target_group.arn
    type             = "forward"
  }
}

# Request and validate an SSL certificate from AWS Certificate Manager (ACM)
resource "aws_acm_certificate" "certificate" {
  domain_name       = var.domain
  validation_method = "DNS"
}

# Request a route53 record
resource "aws_route53_record" "devpod" {
  zone_id = var.hosted_zone_id
  name    = var.domain
  type    = "CNAME"
  ttl     = 300
  records = [aws_alb.alb.dns_name]
}

resource "aws_route53_record" "devpod_records" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.hosted_zone_id
}

resource "aws_acm_certificate_validation" "devpod" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.devpod_records : record.fqdn]
}

# Associate the SSL certificate with the ALB listener
resource "aws_alb_listener_certificate" "certificate" {
  listener_arn = aws_alb_listener.load_balancer_listener.arn
  certificate_arn = aws_acm_certificate.certificate.arn
}