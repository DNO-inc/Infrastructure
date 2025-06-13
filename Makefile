
rm_aws_secrets:
	aws secretsmanager delete-secret --secret-id terraform-test-admin --force-delete-without-recovery

get_aws_secrets:
	aws secretsmanager get-secret-value --secret-id terraform-test-admin --output table

kubectl_setup:
	aws eks update-kubeconfig --name my-eks-cluster
