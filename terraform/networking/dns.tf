##########################################################################################################################################################
#                                                                                                                                                        #
#                                                                                                                                                        #
#                                                                  PRIVATE HOSTED ZONE                                                                   #
#                                                                                                                                                        #
#                                                                                                                                                        #
##########################################################################################################################################################

resource "aws_route53_zone" "main" {
  name = var.kubernetes_domain
  vpc {
    vpc_id = aws_vpc.main.id
  }
}

resource "aws_route53_record" "controlplanes" {
  for_each = var.controlplanes-fqdn
  zone_id = aws_route53_zone.main.id
  name = "${each.key}.${var.kubernetes_domain}"
  type = "A"
  ttl = 300
  records = [each.value]
}

resource "aws_route53_record" "workers" {
  for_each = var.workers-fqdn
  zone_id = aws_route53_zone.main.id
  name = "${each.key}.${var.kubernetes_domain}"
  type = "A"
  ttl = 300
  records = [each.value]
}