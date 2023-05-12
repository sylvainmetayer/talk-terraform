# Les problèmes rencontrés

---

## Version terraform

- <1.0, API non figée
- [0.14.0](https://www.terraform.io/upgrade-guides/0-14.html#provider-dependency-lock-file)

---

## Communication cluster EKS

- [exec plugin](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#exec-plugins)

````terraform [2]
provider "kubernetes" {
  load_config_file       = true
}
````

````terraform [5-9]
provider "kubernetes" {
  host                   = module.eks.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.eks_cluster_certificate)
  load_config_file       = false
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.eks_cluster_name]
    command     = "aws"
  }
}
````

---

## Cluster EKS privé

<img src="/assets/img/access-denied.jpg"  height="400" width="400" alt="Access Denied" >

<small><a href='https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html'>https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html</a></small>

---

### Lifecycle change

```terraform
resource "aws_efs_file_system" "data" {
  lifecycle {
    ignore_changes = [
      number_of_mount_targets,
      size_in_bytes
    ]
  }
}
```

---

## Gestions des secrets

<img src="/assets/img/public-secrets.jpg"  height="400" width="400" alt="Public secrets" >

,,,

### Solutions

- Utiliser AWS Secrets manager
- Utiliser [Hashicorp Vault](https://www.vaultproject.io/)
- Utiliser des variables d'environnements (`TF_VAR_password`)

---

## Dépendance cyclique

---

## AWS SSO

- Nécessité vis à vis de la sécurité
- [Mais intégration terraform KO avec provider AWS](https://github.com/hashicorp/terraform-provider-aws/issues/17353)

,,,

### Contournement

<https://github.com/linaro-its/aws2-wrap#use-the-credentials-via-awsconfig>

````ini [9]
[profile demo_tf]
sso_start_url = https://xxx
sso_region = eu-west-1
sso_account_id = xxx
sso_role_name = AdminAccess
region = eu-west-1
# This allow terraform to access AWS SSO credentials
credential_process = aws2-wrap --process --profile demo_tf
````

Ce contournement n'est plus nécessaire suite à une mise à jour du provider et la cli AWS<!-- .element: class="fragment" data-fragment-index="1" -->

---

#### La réalité derrière la "beauté" du code

<img src="/assets/img/shiny.jpg"  height="500" width="500" alt="Shiny code">
