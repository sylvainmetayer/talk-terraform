# Intro

## pourquoi iac ?

- Retours en arrière facile
- Scalable : besoin de plus de machines? ok
- Suivi des modifications: vous avez git pour votre code ? Vous devriez avoir pareil pour votre infra
- Couts: rejoins la maintenabilité : plus facile a maintenir = moins cher, même si cout initial plus elevé.

reproductilité instance ec2 sur amazon en preprod et prod est identique. identique delta dev sur diff prod/dev

perimetre : Tout, s3, sftp, ec2, reseau, bdd, redis, dns, ... Si vous avez des mix IaC et non IaC, vous allez avoir des soucis

# tf c'est quoi?

- grande communauté et permet de distribuer des modules via une registry communautaire

# outils officiels

- Tous les fournisseurs cloud ne fournissent pas d'outil dédié et préfère participer à un outil open-source (ex ovh hetzner)
- gérer du multi cloud avec un même outil
- Prévenir le vendor lock-in. à nuancer
- Il faut donc par exemple écrire dans le cas d'un module database, un pour AWS et un pour GCP si l'on bouge de AWS vers GCP
- Mitchell Hashimoto

## mots clés TF

- provider : défini le provider utilisé pour déployer la ressource. Ex : AWS. Officiel / communautaire.
- locals : variable local au fichier
- variable : paramètres fourni à l'execution de terraform pour le module ou le(s) fichier(s).

- state: décrit etat infra selon terraform et tous les attributs des ressources gérés par TF. Permet le calcul de diff pour déterminer le plan des actions à effectuer sur le cloud provider.

- data: données récupérées depuis le cloud provider. Ex : type d'instance EC2 qui retourne donc tous les attributs d'une ressource.
- resource : définition de ce que l'on va déployer. Arguments

# pourquoi terraform

Au début, pas de fournisseur cloud dédié (AWS, mais possibilité de Google Cloud). Le choix de Terraform semblait donc
pertinent dans le cas ou le fournisseur viendrait à changer (meme si ce ne fut finalement pas le cas)

reality: 1er projet terraform, on ne peut pas faire quelque chose de parfait au premier coup.

- Pas une maturité suffisante pour mettre ça en place au sein de l'équipe.
- Des débuts hésitants et peu de maitrise de l'outil au début (courbe d'apprentissage)
  - Réticent au 100% automatisé au début par peur de voir des erreurs / effets de bord non maitrise
- Recommandation d'architecture AWS pas incompatible mais baby steps pour mettre en place le tout
- paramètres par environnement via variables pas workspace

La chaine CI/CD automatisée pourrait désormais se penser au sein du projet, mais certaines contraintes de sécurité
nécessiterait des adaptations :

- AWS SSM Session Manager restreint l'accès aux machines pour des raisons de sécurité.
- Cluster EKS privé, donc nécessite de lancer les commandes terraform relatives au module EKS depuis une instance EC2 accessible depuis Session Manager uniquement
- SSM / restriction flux endpoint / subdivision subnet private / public

## demo

init plan apply output ssh curl sed apply state state show state rm import taint apply

commencer par variables.tf puis terraform.tfvars puis default.html.tpl puis main.tf

## version terraform

Avant la version 0.14.0, les dépendances des providers étaient toujours par rapport à la dernière version disponible
lors d'un `terraform init` (sauf à définir un required version dans block terraform pour une version figée et non contrainte)

# eks

Le provider Kubernetes n'était pas toujours disponible une fois installé, car le fichier de configuration kubernetes `~/.kube/config` n'était pas à jour puisque cluster nouvellement créé. Nous avons donc modifié les paramètres du provider kubernetes pour récupérer un token d'authentification avec la cli AWS, en utilisant un exec plugin (comme recommandé dans la doc. Moralité : Lisez la doc)

# eks privé

Le créateur du cluster EKS est le seul qui l'administre. Lors de nos tests initiaux avec nos comptes nominatifs, il nous est donc arrivés de voir que l'on ne pouvait pas mettre à jour/accéder aux caractéristiques du cluster depuis terraform car nous ne l'avions pas créé.

A cela s'est ajouté le besoin de sécurité d'avoir l'API du cluster EKS privé (bonne pratique AWS), afin d'éviter toute compromission en dehors du réseau AWS. Cette contrainte a finalement permis de résoudre le premier soucis, puisque le fait de déployer le cluster EKS sur le réseau AWS oblige donc à déployer l'EKS depuis une instance EC2 d'administration dédiée avec un rôle d'instance dédié, qui est donc le créateur du cluster EKS.

# lifecycle

Les métadonnées terraform peuvent changer au fur et à mesure de la vie d'une ressource. Mais il n'est pas forcément nécessaire de les mettre à jour pour autant. Il existe donc une option pour ignorer les changements de certains attributs `ignore_change`.

# secrets

- Et charger via les data ressources les valeurs des secrets. Cela nécessite donc d'avoir tous les secrets dans Secrets Manager (et donc de les payer + configurer manuellement).
- Qui peut s'intégrer avec terraform. Nécessite une brique d'infrastructure supplémentaire
- Nécessite que tous les intervenants aient les différents secrets sous peine de voir les base de données se recréer
    par exemple. Solution retenue, car la moins couteuse en mise en place/cout venant de notre situation initiale.

# dépendances cyclique

Certaines ressources sont transverses (exemple : IAM pour la gestion des rôles). À compartimenter par besoins fonctionnels, nous avons réparti des rôles IAM dans différents modules alors qu'ils sont nécessaires dans plusieurs modules qui rentrent parfois dans des soucis de dépendances cycliques (`eks -> network` pour connaitre le nom du cluster eks et `network -> eks` pour connaitre l'id du vpc). Cela a donc obliger à faire attention à cela lors de nos développements et à inclure beaucoup de depends_on. Le même souci a été rencontré pour les clés [KMS](https://aws.amazon.com/fr/kms/) qui sont également transverses. Avec du recul, la solution serait donc d'avoir un module transverse pour ce type de ressources.

# aws sso

Contrainte de sécurité pour éviter que des comptes aws user par account soient utilisés, il fut compliqué de l'intégrer à terraform. De plus, soucis du provider terraform et de la CLI AWS pour une version donnée qui a nécessité d'utiliser un wrapper python pour que terraform communique correctement avec.

Avant une certaines version de la CLI AWS et de la version du provider AWS, il fallait utiliser un paquet pip supplémentaire pour que terraform puisse accéder aux identifiants AWS.

# beauté derriere code

Ne connaissant ni Terraform, ni AWS avant ce projet, il fut nécessaire d'apprendre Terraform et AWS en même temps. Ce fut formateur, mais parfois, des problèmes AWS ont posés soucis, ne sachant pas comment créer telle ou telle ressource. Cela a donc amené à parfois tester sur l'interface AWS, vérifier que cela fonctionne bien, comprendre le fonctionnement AWS, et ensuite regarder s'il était possible d'effectuer un import de la ressource dans terraform, et ajuster les tags/attributs pour faire un code propre.

# orga projet

avant :

- obligé de préciser les vars file à la main, pas pratique car option à rallonge
- profil AWS a definir à la main a chaque fois et ne pas oublier lors de changement de contexte

apres

- Organisation par environment dans des dossiers avec des liens symboliques.
- Usage de `direnv` qui autocharge les variables d'environnements nécessaires (exemple : nom profil AWS)
- La cli terraform peut s'utiliser directement sans argument, plus facile pour se focaliser sur les options
  importantes (apply/plan)
- auto chargement des env vars avec des `auto.tfvars`

# ecosysteme

tests : Permet de tester que l'infrastructure est fonctionnelle. On écrit du code, donc on doit le tester. kitchen : framework de test d'IaC ayant un plugin pour tester TF

sentinel: permet de forcer des cohérences sur l'infra, d'appliquer des policies sur l'infra afin de s'assurer de sa sécurité/conformité. Exemple : toutes les ressources devraient avoir un tag.

tfsec Permet de lever les soucis de sécurité dans ce qui est déclaré (ex: security group ouverte en 0.0.0.0)

terragrunt : Le plus connu, ajoute certaines fonctionnalité à terraform, tel que par exemple auto init des modules + auto création du remote state sur un bucket pour le state si manquant.

tfcloud : Produit commercial de hashicorp qui met à dispostiion une plateforme pour gérer le state et les déploiement auto, s'intègre avec git, gère les ACLs d'accès au pipeline...
