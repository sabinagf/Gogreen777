resource "aws_route53_zone" "general" {
  name = "ziyotekgogreen.net"
}

resource "aws_route53_record" "alias_route53_record" {
  zone_id = aws_route53_zone.general.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.webtier_alb.dns_name
    zone_id                = aws_lb.webtier_alb.zone_id
    evaluate_target_health = true
  }
}
resource "aws_acm_certificate" "acm_certificate" {
  domain_name       = var.domain_name
  validation_method = "DNS"
}

# resource "aws_route53_record" "example_validation" {
#   name    = aws_acm_certificate.example.domain_validation_options.0.resource_record_name
#   type    = aws_acm_certificate.example.domain_validation_options.0.resource_record_type
#   records = [aws_acm_certificate.example.domain_validation_options.0.resource_record_value]
#   zone_id = var.domain_name
#   }
