# 4. Ecosystème / Communauté

speaker:

- Communauté importante et active
- Beaucoup d'outils permettent d'améliorer terraform
- préciser que tous n'ont pas été testé et que cela est loin d'être exausthif

---

## Tests

|||
|---|---|
|Terratest|<https://terratest.gruntwork.io/>|
|Kitchen Terraform|<https://newcontext-oss.github.io/kitchen-terraform/>|

speaker:

Permet de tester que l'infrastructure est fonctionnelle. On écrit du code, donc on doit le tester.

Non mis en place actuellement, mais envisagé lors d'évolution afin de valider que le nouveau code est conforme à ce qui
est déployé.

Il est préférable d'utiliser des workspace pour cela.

framework de test d'IaC ayant un plugin pour tester TF

---

## Conformité

|||
|---|---|
|Sentinel|<https://docs.hashicorp.com/sentinel/terraform>|
|TfSec|<https://github.com/aquasecurity/tfsec>|

speaker:

Permet de lever les soucis de sécurité dans ce qui est déclaré (ex: security group ouverte en 0.0.0.0)

---

## Terragrunt

<https://terragrunt.gruntwork.io/>

speaker:
Le plus connu, ajoute certaines fonctionnalité à terraform, tel que par exemple auto init des modules + auto création du remote state sur un bucket pour le state si manquant.

---

## Terraform Cloud

<https://cloud.hashicorp.com/products/terraform>

speaker:

Produit commercial de hashicorp qui met à dispostiion une plateforme pour gérer le state et les déploiement auto, s'intègre avec git, gère les ACLs d'accès au pipeline...

---

## Terraform CDK

<https://www.terraform.io/cdktf>

<img src="/assets/img/cdk.png"  height="480" width="480" alt="CDK">

---

## Weekly.tf

<https://weekly.tf/>
