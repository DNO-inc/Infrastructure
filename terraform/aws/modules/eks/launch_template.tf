resource "aws_launch_template" "eks_node_group" {
  name_prefix = "${var.cluster_name}-eks-node-group"
  description = "Launch template for ${var.cluster_name} EKS node group"

  vpc_security_group_ids = toset(
    concat(
      [
        aws_security_group.eks_cluster.id,
        aws_security_group.eks_nodes.id
      ],
      var.additional_node_sg
    )
  )

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      delete_on_termination = true
    }
  }

  tags = {
    "Name"                                      = "${var.cluster_name}-eks-node-group"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }

  lifecycle {
    create_before_destroy = true
  }

  maintenance_options {
    auto_recovery = "default"
  }
}
