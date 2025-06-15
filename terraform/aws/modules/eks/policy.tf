data "http" "eks_alb_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.13.0/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "aws_lb_controller" {
  name = "AWSLoadBalancerControllerIAMPolicy"
  path = "/"

  policy = data.http.eks_alb_policy.response_body
}
