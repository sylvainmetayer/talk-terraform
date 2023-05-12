## Organisation projet

```bash []
├── deploy
│   ├── main.tf
│   └── variables.tf
├── modules
│   ├── eks
│   ├── network
│   ├── tool-server
│   └── website
├── parameters
│   ├── dev
│   ├── preprod
│   └── prod
```

```bash
$ terraform state show aws_instance.web -var-file=./params/dev/params.tfvars
```

,,,

### Maintenant

```bash []
├── dev
│ ├── config.auto.tfvars
│ ├── .envrc
│ ├── .env.secrets
│ ├── main.tf -> ../src/main.tf
│ ├── .terraform.lock.hcl -> ../src/.terraform.lock.hcl
│ ├── terraform.tfvars
│ └── variables.tf -> ../src/variables.tf
├── preprod
├── prod
├── src
│ ├── main.tf
│ ├── modules
│ ├── .terraform.lock.hcl
│ └── variables.tf
├── .tool-versions
```

```bash
$ terraform state show aws_instance.web
```

,,,

### Mais perfectible

Bug Terraform `.terraform.lock.hcl` : <https://github.com/hashicorp/terraform/issues/27158>
