# Démo terraform

## Déployer une instance EC2 avec nginx + ipv4 (workspace dev)

```bash
cd hello-world
terraform init
terraform apply
cd ../demo
terraform init
terraform plan
terraform apply
# montrer output
ssh ec2-user@xyz
# ouvrir http://xyz
# ouvrir console AWS et voir instance avec tags

# modifier le default.html.tpl et constater que KO
# Expliquer que à cause du lifecycle ignore change
terraform state list
terraform state show aws_instance.web
# Note arn instance ec2 instance-id (i-*)
terraform state rm aws_instance.web
terraform import aws_instance.web XXX
terraform taint aws_instance.web
terraform apply
terraform fmt -recursive .
```

## Déployer une instance EC2 workspace prod avec assert tag prod + ipv4 defined

constater que si tag != => KO

<https://terratest.gruntwork.io/docs/getting-started/quick-start/#example-2-terraform-and-aws>

racine projet, à faire une fois :

`go mod init demo_tf.com/m/v2`

- prévoir 5min de délai

```bash
go mod tidy
cd hello-world
go test -v
cd ../demo
terraform workspace new test
go test -v
```

## Destroy

```bash
terraform workspace select prod
terraform destroy
terraform workspace select default
terraform destroy
```
