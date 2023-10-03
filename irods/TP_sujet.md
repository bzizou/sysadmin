TP installation et configuration iRods
======================================

*Vous allez installer et configurer un petit espace de stockage distribué avec iRods, de manière collaborative. Ce TP est destiné à vous faire "jouer" un peu avec l'outil. Vous allez donc chercher, peut-être galérer un peu, mais c'est le but! Vous aurez sûrement besoin d'aide et votre serviteur sera à votre disposition, n'hésitez pas à le solliciter!*


# Connexion aux VM

Répartition des VM `ust4hpc-data0` à  `ust4hpc-data9` en binome

SSH admin@ust4hpc.ust4hpc -> ust4hpc-data[0-9].ust4hpc

Machine cliente: admin@ust4hpc-client.ust4hpc

Nous allons créer une ressource de stockage sur chaque VM et les mettre en commun pour créer un espace distribué unique, nommé "aussois". 

La doc oficielle nous sera très utile! -> https://docs.irods.org/4.3.0/

# Installation des paquets (Debian Bullseye)


Sur votre VM, installez les paquets:

```bash
wget -qO - https://packages.irods.org/irods-signing-key.asc | apt-key add -
echo "deb [arch=amd64] https://packages.irods.org/apt/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/irods.list
apt-get update
apt-get install irods-server
```


# Setup irods

Voir https://docs.irods.org/4.3.0/getting_started/installation/


## Master node (meta-data = Catalog Service Provider ; historiquement "iCat")

Nous allons tout d'abord configurer ensemble le noeud meta-catalogue. Notez bien les étapes, car pour configurer vos ressources, ce sera très similaire.

NOTE: Avec les versions récentes de Postgres, il peut être nécessaire de faire `ALTER DATABASE "ICAT" OWNER TO irods;`

## Sur les noeuds de data

On va créer une ressource de stockage par noeud, et les agréger dans la ressource
composée distribuée "aussois" qui vient d'être préparée sur le meta-catalogue.

Lancez maintenant sur votre VM, le script de config:

```bash
python3 /var/lib/irods/scripts/setup_irods.py
```

Pensez bien à choisir  le mode `Consumer` cette fois-ci et mettez bien les mots de passe et clés créés précédemment:

- Zone: "ust4hpc"
- Repondre "yes" à "Local storage", et appeller la resource de stockage comme le nom du noeud (ex: ust4hpc-data2)
- Password: ust4hpc
- Salt, Key : "UST"
- Negociation & Control Plane KEY (32 chars): "UST4HPC3UST4HPC3UST4HPC3UST4HPC3"

Lancez irods:

```bash
/etc/init.d/irods start
```

Intégrer la nouvelle ressource à la ressource parente "aussois" tout en prenant soin d'intercaler des ressources "Passhru" afin de permettre d'affecter des poids.

Voir https://docs.irods.org/4.3.0/icommands/administrator/#mkresc

Note: les commandes d'admin (user 'rods', configuré sous le compte 'irods') peuvent être éxécutées depuis n'importe quel serveur irods, que ce soit le meta-ctalogue (Provider) ou une ressource de stockage (Consumer).

```bash
su - irods
#  Création de ressource "passthru" permettant de régler des poids lecture/ecriture
iadmin mkresc ust4hpc-data<num>-pt passthru '' 'write=1.0;read=1.0'
# Affiliation de la ressource de stockage à la ressource passthru
iadmin addchildtoresc ust4hpc-data<num>-pt ust4hpc-data0
# Affiliation de la ressource passthru à la ressource composée "aussois"
iadmin addchildtoresc aussois ust4hpc-data<num>-pt
```

Vérifiez:

```
irods@ust4hpc:~$ ilsresc
```

Créer un utilisateur iRods (login de votre choix) dans la base locale afin de pouvoir tester. Pour cela, allez dans la doc et utilisez la commande `iadmin mkuser`: https://docs.irods.org/4.3.0/icommands/administrator/#mkuser

## Configuration d'un client

Sur ust4hpc-client, nous installerons ensemble les paquets clients:

```bash
wget -qO - https://packages.irods.org/irods-signing-key.asc | apt-key add -
echo "deb [arch=amd64] https://packages.irods.org/apt/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/irods.list
apt-get update
apt-get install irods-icommands
```

Sur cette machine, créez-vous maintenant un compte unix (`useradd <user> -s /bin/bash -m -d /home/<user>`) et configurez le pour accéder à irods, en utilisant la commande `iinit` et en configurant la connexion vers le serveur principal `ust4hpc`

```bash
su - <user>
iinit
```

Vous pouvez vérifier la config générée dans ~/.irods/irods_environment.json

IMPORTANT: chaque serveur irods, qu'il soit provider ou consumer agit en fait comme un "proxy". Les clients peuvent s'y connecter indifféremment pour accéder à la "boucle irods" ainsi créee. Certaines règles vont alors pouvoir être mises en place et agir différemment en fonction du serveur utilisé par les clients. Nous verrons cela après. Pour le moment, nous nous connectons directement sur le meta-catalogue, mais ce n'est généralement pas conseillé! 

Faites des tests de transfert de fichiers avec `iput` et `iget`. Utilisez `ils -L` pour vérifier la localisation de vos fichiers. Que constatez-vous?

Ils ne sont pas au bon endroit! 

Que faut-il faire pour les envoyer vers notre ressource distribuée "aussois" ? (spoil: voir l'option -R de iput...)

C'est le moment de jouer avec quelques commandes sympa:
- L'option `-r` de `iput` permet de transférer un répertoire récursivement, faites-le et observez que les données soient bien distribuées aléatoirement sur les différentes ressources de stockage ;
- Essayez de créer des réplicats avec `irepl`; 
- Jouez un peu avec `imeta` pour créer des meta-données et les interroger ;
- Utilisez `iquest` pour obetnir des informations ou des stats ;
- Pour supprimer des fichiers: `irm`

Optionel, (pour ceux qui vont trop vite!): créez 2 nouvelles ressources de stockage sur votre serveur (`iadmin mkresc` en choisissant 2 répertoires différents) et associez-les dans une ressource composée de type `replication` pour que lorsqu'un fichier est déposé, il soit automatiquement répliqué (2 copies du fichier sont systématiquement crées). Voir https://docs.irods.org/4.3.0/plugins/composable_resources/#replication

## Configuration des règles

### Règles de base

Nous allons maintenant configurer nos ressources en simulant une certaine proximité préférentielle: les données poussées vers irods seront mises en priorité sur une ressource définie. On va donc supprimer notre ressource distribuée "aussois" et utiliser directement nos petites ressources. Chaque client va envoyer ses données en passant par un serveur défini et les données seront déposées sur ce serveur. 

Commencez par enlever votre ressource de la ressource parent "aussois":

```bash
iadmin rmchildfromresc aussois ust4hpc-data<num>-pt
```

Pour vérifier ce fonctionnement, nous allons tous utiliser le même login "rods" cette fois-ci, mais depuis des clients différents qui seront simulés par nos comptes unix.

Sur la machine cliente ust4hpc-client, dans le compte que vous avez créé, supprimez le fichier `rm ~/.irods/irods_environment.json` refaites donc "iinit" mais cette fois-ci, mettez le login "rods" et son mot de passe "ust4hpc" et surtout, utilisez votre VM comme serveur irods et non plus le serveur principal. Editez le fichier `~/.irods/irods_environment.json` et enlevez l'éventuelle ligne qui définit "irods_default_resource" car elle entrerai en conflit avec notre configuration "server-side".

Sur le serveur de votre ressource, les règles sont configurées dans le fichier `/etc/irods/core.re`. Ouvrez le et cherchez la ligne qui commence par `acSetRescSchemeForCreate`. Vous verrez que le script de configuration y a mis automatiquement le nom de votre ressource comme paramètre du microservice `msiSetDefaultResc`. Changez ici, et mettez une autre resource parmis toutes les ressources passthru qui ont été créee et libérée un peu plus tôt; inutile de relancer le service, la modification est automatiquement prise en compte. Déposez des fichiers depuis le client avec un simple `iput` (sans préciser de `-R`) et constatez (`ils -L`).

Note: la ressource par défaut qui a été configurée ne fonctionnerai pas, puisque nous avons intercalé des ressources "passthru". On aurait un message d'erreur "DIRECT ACCESS TO CHILD".

### Création d'une règle de stage-in automatique

Dans le cas d'une grille de stockage iRods avec plusieurs sites, il peut être également interessant de répliquer les données sur les ressources d'un site avant de les exploiter depuis les clients. Nous allons mettre en place une règle qui fait cette réplication automatiquement sur la ressource locale, dès qu'un fichier lu n'est pas déja répliqué.

Ajoutez simplement ces lignes à la fin du fichier `/etc/irods/core.re` en prenant soin de remplacer le nom de la ressource par celui de votre ressource:

```
pep_api_data_obj_get_pre(*INSTANCE_NAME, *COMM, *DATAOBJINP, *BUFFER, *PORTAL_OPR_OUT) {
  msiDataObjRepl(*DATAOBJINP.obj_path,"ust4hpc-data<num_ressource>-pt",*status);
}
```

Maintenant, faites un `iget` d'un fichier que vous avez déposé sur une autre ressource avant. Et faites un `ils -l`. Vous constaterez qu'un nouveau réplicat local a été créé!
Mais si vous refaites maintenant un `iget`, vous avez une erreur car un réplica existe déja. Il faut alors rajouter un test pour ne répliquer que lorsque cela est nécessaire. Saurez-vous écrire ce test? Perso, je n'ai pas encore trouvé, haha! Mais suivez ce thread, la réponse y sera sûrement prochainement: https://groups.google.com/g/iROD-Chat/c/HSkxZDYLD2I

EDIT: La règle complète, suite à la discussion ci-dessus sur le chat irods:

```
pep_api_data_obj_get_pre(*INSTANCE_NAME, *COMM, *DATAOBJINP, *BUFFER, *PORTAL_OPR_OUT) {
  msiSplitPath(*DATAOBJINP.obj_path, *target_collection, *target_data_object); # see https://docs.irods.org/4.3.0/doxygen/msiHelper_8cpp.html#a5de988327f1dfe917bcc0bfbac1087ec
  *target_resource_root = 'ust4hpc-data1-pt';
  *query = SELECT count(DATA_ID) where COLL_NAME = '*target_collection' and DATA_NAME = '*target_data_object' and DATA_REPL_STATUS = '1' and DATA_RESC_HIER like '*target_resource_root;%'
  foreach (*result in *query){
    *good_replica_count_on_resource = int(*result.DATA_ID);
    if (*good_replica_count_on_resource == 0) {
        msiDataObjRepl(*DATAOBJINP.obj_path,"*target_resource_root",*status);
    }
  }
}
```

### Mise en place du moteur de règles python sur un exemple mettant en jeu les meta-données

Nous allons mettre en place le moteur de règles python et générer l'extraction des "EXIF" à chaque fois qu'une image est uploadée.


Sur votre ressource, installez le plugin python:

```bash
apt-get install -y irods-rule-engine-plugin-python python2.7
```

Installez "pip" et "python-exif" pour python2:

```bash
wget https://bootstrap.pypa.io/pip/2.7/get-pip.py
python2 get-pip.py
python2 -m pip install exifread==2.3.2
```

Récupérez l'exemple de règle python et jettez un oeil au code
```bash
wget https://raw.githubusercontent.com/bzizou/sysadmin/master/irods/core.py -O /etc/irods/core.py
vi /etc/irods/core.py
```

Editez `/etc/irods/server_config.json` et ajoutez le python-plugin dans la section "rule_engines":

```
[...]
"rule_engines": [
 {
 "instance_name" : "irods_rule_engine_plugin-python-instance",
 "plugin_name" : "irods_rule_engine_plugin-python",
 "plugin_specific_configuration" : {}
 },
 {
 "instance_name": "irods_rule_engine_plugin-irods_rule_language-instance", 
[...]
```

Ajoutez `metadata` dans `re_rulebase_set` (on peut donner le nom qu'on veut ici)

```
"re_rulebase_set": [
 "metadata",
 "core"
 ],
```

Creez le fichier correspondant "metadata.re":

```
cat <<EOF >  /etc/irods/metadata.re
add_metadata_to_objpath(*str, *objpath, *objtype) {
 msiString2KeyValPair(*str, *kvp);
 msiAssociateKeyValuePairsToObj(*kvp, *objpath, *objtype);
}
getSessionVar(*name,*output) {
 *output = eval("str($"++*name++")");
}
EOF
```

Testez avec un fichier image:

```bash
wget -O /tmp/ngc7000.jpg https://github.com/bzizou/sysadmin/blob/0b7004b67d284116d0f7e9432bb257f269eb05c0/irods/ngc7000.jpg
su - irods
iput /tmp/ngc7000.jpg
irods@ust4hpc-data1:~$ imeta ls -d ngc7000.jpg
```

Vous devez voir les informations "EXIF" de l'image importée sous la forme de meta-données irods!

Er... shit... : https://github.com/irods/irods_rule_engine_plugin_python/issues/156

Ce TP marchera un jour ;-)

# Pour aller plus loin
Vous pouvez jetter un oeil à ce cas d'usage, qui comporte du code opérationnel: https://jcad2022.sciencesconf.org/data/027_Presentation_courte_Bruno_Bzeznik_iRods_pour_le_projet_Orchamp.PDF
