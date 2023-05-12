# Plan

ton de présentation à voir pour les slides : un truc constant entre les slides : oriené en mode pas à pas évolutif

pas une pres aws sourcer tout ce qui est dit.

Nom présentation : TBD

## Infra as Code : 3min

préparation : une demie journée

- Définition
- Pourquoi faire ? meme sur petit volume

- repeteable reproductible scalable tranquikkté d'esprit
- 12 factors (?)

- historique (schéma ? Courbe à voir)
- définition vs ma vision

## Cas d'usage de terraform : 3min

préparation : 1h

- Pour du "non cloud" (OVH, hetzner) / multi cloud
- prévenir le vendor lock-in (à nuancer)
- définir infra + la faire évoluer / scaler

## ALternatives : 1/2min pendant démo

préparation : 1h

- cloudformation (AWS)
- <https://cloud.google.com/deployment-manager/docs> (Gcloud)
- <https://azure.microsoft.com/fr-fr/features/resource-manager/> (Azure) Azure template manager

## Cas de non usage: 1min

préparation : 1h

- Ansible != terraform
- <https://www.terraform.io/intro/vs/chef-puppet.html>
- <https://www.hebergeurcloud.com/pourquoi-utilise-t-on-terraform-et-non-chef-puppet-ansible-saltstack-ou-cloudformation>
- config infra vs config applicative

<https://www.terraform.io/docs/language/state/purpose.html>

## Le cas d'un projet 5min max

préparation : 2 jours

- Terraform car fournisseur cloud non défini au début
- Schéma applicatif :2/3 slides macro

## Trucs à parler 10min

préparation : 1j

- Modules
- parameters
- Tag + locals
- présentation des commandes basiques : apply / plan / state refresh / import / graph

## demo : 5min

préparation : 1j toutes confondues

caler la démo ici

démo : une ec2 + nginx + ipv4

### State of the art vs réalité : 5/7min

préparation : 1j + 1j slides

- un env = un workspace
- chaine CI/CD avec terraform plan/apply depuis CI/CD une fois MR passée

<https://www.terraform.io/docs/cloud/guides/recommended-practices/part2.html> : semi automated :

Réalité : pas assez grande maturité projet pour ça. tout n'est pas terraform (partie cloudformation). Attention, sujet
politique à aborder avec légéreté. pas de maitrise de l'outil (terraform) au début donc réticent au full auto.
Maintenan,t pourrait s'envisager avec quelques adaptaion (ssm + complexité d'accès)

## demo 2 : 5min

demo changer de workspace avec changement de tag dev => prod démo : un VPC + une ec2 + nginx + ipv4

<https://itnext.io/multi-environment-infrastructure-provisioning-on-aws-using-terraform-1ee8d377c560>

### organisation projet : 3/4min pendant démo

préparation : 2h

Présenter l'infra avant après refacto.

## Trucs réalisés / Problèmes rencontrés : 5/7min

préparation : 2h

- TfState backend (bucket S3)
- Iteration multiples (single account au début, multi account ensuite)
- AWS SSO (contrainte) : ref issue githib fixé depuis.
- Test manuels +import + config terraform + tf import : derrière la beauté du code qui marche.
- gestion secret par injection environnement / voir si env pas passé ?

probleme

- Stabilité terraform (0.12.26 => 1.0.8) avant la 1.0.0
- EKS privé : déploiement via l'EC2 :owner du cluster qui est le ec2
- lifecycle diff state (ignore_change)
- AWS SSO
- provider kube une fois déployé : comment communiquer avec (aws eks get token) : service dans cluster eks qui fait le
  role avec iam + méconnaissance
- gestion secret : AWS secret manager / vault
- module iam devrait être à part plutôt que dispatché par module car besoin transerve. Idem KMS;. Avec le recul, aurait
  dû être fait comme ça.

### Optimisation / idées : ouverture 3/4min

préparation : 2/3j

communauté / écosysteme + outils liés

- Tflint
- [tfsec](https://github.com/aquasecurity/tfsec) : à voir si utile / pertinent
- TfValidate
- Jenkins jobs validate + lint
- virer les paramètres de variables en cli pour ne garder que terraform plan/apply + target
- Gestion workspace ou 1 tfstate par env ? 1 fichiers de variables vs 3 fichiers de variables
  - <https://www.padok.fr/en/blog/terraform-aws-accounts>
- Gestion secrets : vault ? <https://blog.gruntwork.io/a-comprehensive-guide-to-managing-secrets-in-your-terraform-code-1d586955ace1>
- terragrunt : usage +/- limité mais existe
- <https://terratest.gruntwork.io/>
- comparatif gcp module mail
- intégrer ressoruce kube dans tf (ex version à changer + piloter la): nous autotisé autrement

## demo 3 : 5min

lancer les tests sur demo2

- <https://terratest.gruntwork.io/> avec aun assert que l'instance à une ipv4 avec port 80 ouvert

### Ressources à l'arrache

- <https://thenewstack.io/terraform-on-aws-multi-account-setup-and-other-advanced-tips/>
- <https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html>
- <https://github.com/pwillis-els/terraformsh/blob/main/PHILOSOPHY.md>
- Terraform weekly
- <https://terrastruct.com/>
- <https://github.com/GoogleCloudPlatform/terraformer>
- <https://github.com/keilerkonzept/terraform-module-versions?utm_campaign=weekly.tf&utm_medium=email&utm_source=Revue%20newsletter>
- <https://www.padok.fr/en/blog/terraform-aws-accounts>
- <https://www.reddit.com/r/Terraform/comments/rpiaj2/any_way_of_transforming_a_requirementstxt_file_to>
- <https://www.reddit.com/r/Terraform/comments/ripzg4/execute_bash_script_for_virtual_machine_user_data/>
- <https://www.reddit.com/r/Terraform/comments/rp22g5/optimizing_aws_workflows_with_the_cdk_for/>
- <https://jcdan3.medium.com/getting-started-with-terraform-cdk-f7e728403ca2>
- <https://www.reddit.com/r/Terraform/comments/ropcxn/terraform_advanced_learning/>
- <https://www.reddit.com/r/Terraform/comments/rbbibs/how_does_everyone_structure_their_terraform/>
- <https://brendanthompson.com/posts/2021/12/terraform-variable-validation>
- <https://www.reddit.com/r/devops/comments/lbowxb/best_static_code_analysis_tool_for_terraform/>
- <https://www.reddit.com/r/Terraform/comments/pfcq4x/terraform_configuration_managementorchestration/>
- <https://www.reddit.com/r/devops/comments/q9s2vq/cant_justify_terraform_an_ansible_perspective/>
