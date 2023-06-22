Installation and use case of python rules engine on Mantis
==========================================================

Set up of the acPostProcForPut rule in python, to automatically update the EXIF informations into the meta-data for the upload of an image.

Documentation 
-------------

* (en Français!, merci Jerome!) :

https://indico.in2p3.fr/event/23075/contributions/90180/attachments/61890/84544/08_Moteur_Regles.pdf

Original slides:

https://slides.com/jasoncoposky/cines-2020-rule-engine-plugins

Full beginner training:

https://github.com/irods/irods_training/blob/main/beginner/irods_beginner_training_2019.pdf

Python rule engine plugin Readme:

https://github.com/irods/irods_rule_engine_plugin_python/blob/main/README.md


Set up
------

* Work made on production servers! So, at each step, we do a check to see if everything is stil ok:


```
root@nigel-0:~# /usr/local/etc/monit/scripts/check_mantis_filetest_small.sh
```

Also monitor the logs:

```
root@nigel-0:~# tail -f /var/lib/irods/log/rodsLog.2022.04.11
```

* Dependencies:

```
# Install python-exif module on all the mantis (irods) servers:
clush -bw @mantis "apt-get install -y python-exif"
```

* Setup the python plugin

```
clush -bw @mantis "LANG=C apt-get install -y irods-rule-engine-plugin-python"
clush -bw @mantis "touch /etc/irods/core.py"
```

Edit `/etc/irods/server_config.json` and add the python plugin, as explained into the slides, on every resource!

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

Add `metadata` into `re_rulebase_set` (we can call it whatever we want, the original training doc sets `training` here; on every resource!

```
"re_rulebase_set": [
 "metadata",
 "core"
 ],
```

Create the corresponding rule file (on every resource)

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

Customization
-------------

Main customizations goes into the versionned file: https://gricad-gitlab.univ-grenoble-alpes.fr/ciment/system/-/blob/master/clusters/mantis2/core.py

* Install the customized python plugin definition on all the resources

```
root@f-dahu:/home/bzizou/git/system/clusters/mantis2# clush -bw @mantis --copy core.py --dest /etc/irods/core.py
```

OAR jobs trigger
----------------

To trig jobs on OAR clusters, we are going to use the OAR API. At GRICAD, CiGri already uses a specific https config to submit jobs, and we are simply going to use the same configuration.

* Copy the cert and private key of cigri to the iRods meta host (nigel-0). We should have:

```
irods@nigel-0:~$ ls -l /etc/cigri/ssl/cigri.*                     
-rw-r--r-- 1 irods root 3364 Oct 15  2013 /etc/cigri/ssl/cigri.crt
-r-------- 1 irods root  887 Oct 15  2013 /etc/cigri/ssl/cigri.key
```

* Do a simple test with curl, to see if the irods host can submit jobs:

```
curl -X POST -H "Content-Type: application/json" -H "X-Remote-Ident: bzizou" -d '{"scanscript": "", "command": "./mantis/orchamp.oar"}' https://bigfoot:6669/oarapi-cigri/jobs --insecure --cert /etc/cigri/ssl/cigri.crt --key /etc/cigri/ssl/cigri.key
```

The cigri key is old, and may require lowering the security level by commenting `#CipherString = DEFAULT@SECLEVEL=2` into `/etc/ssl/openssl.cnf`.


* Ensure python-pycurl is installed

* The user should have a OAR script into a `mantis` directory inside it's home directory

```
bzizou@bigfoot:~$ cat mantis/orchamp.oar 
#!/bin/bash

#OAR -l /nodes=1/gpu=1,walltime=00:05:00
#OAR -p gpumodel='A100' or gpumodel='V100'
#OAR --project orchampvision

echo $1
nividia-smi -L
```

* Put a file with a name like `<scriptname>.<hostname>.oar-autosubmit`

```
$ iput orchamp.oar_bigfoot.u-ga.fr_oar-autosubmit
```

* Check the logs

```
root@nigel-0:~# tail  -18 /var/lib/irods/log/rodsLog.2022.04.11 


Apr 15 18:46:10 pid:25895 NOTICE: writeLine: inString = PYTHON - acPostProcForPut() complete
Apr 15 18:51:02 pid:26123 NOTICE: writeLine: inString = Submitting OAR job orchamp.oar as bzizou on bigfoot.u-ga.fr
Apr 15 18:51:02 pid:26123 NOTICE: writeLine: inString = {
   "id" : 8538,
   "cmd_output" : "[ADMISSION RULE] Modify resource description with type constraints\nOAR_JOB_ID=8538\n",
   "api_timestamp" : 1650041462,
   "links" : [
      {
         "href" : "/oarapi-cigri/jobs/8538",
         "rel" : "self"
      }
   ]
}


Apr 15 18:51:02 pid:26123 NOTICE: writeLine: inString = PYTHON - acPostProcForPut() complete
```

* Check the job

```
bzizou@bigfoot:~$ oarstat -fj 8538
Job_Id: 8538
    job_array_id = 8538
    job_array_index = 1
    name = 
    project = orchampvision
    owner = bzizou
    state = Waiting
    wanted_resources = -l "{type = 'default'}/network_address=1/gpu=1,walltime=0:5:0" 
    types = 
    dependencies = 
    assigned_resources = 
    assigned_hostnames = 
    queue = default
    command = ./mantis/orchamp.oar /mantis/home/bzizou/orchamp.oar_bigfoot.u-ga.fr_oar-autosubmit
    launchingDirectory = /home/bzizou
    stdout_file = OAR.8538.stdout
    stderr_file = OAR.8538.stderr
    jobType = PASSIVE
    properties = (((gpumodel='A100' or gpumodel='V100') AND devel = 'NO') AND desktop_computing = 'NO') AND drain='NO'
    reservation = None
    walltime = 0:5:0
    submissionTime = 2022-04-15 18:51:02
    cpuset_name = bzizou_8538
    initial_request = oarsub --scanscript ./mantis/orchamp.oar /mantis/home/bzizou/orchamp.oar_bigfoot.u-ga.fr_oar-autosubmit; #OAR -l /nodes=1/gpu=1,walltime=00:05:00; #OAR -p gpumodel='A100' or gpumodel='V100'; #OAR --project orchampvision
    message = R=10,W=0:5:0,J=B,P=orchampvision (Karma=0.000,quota_ok)
    scheduledStart = 2022-04-15 20:01:23
    resubmit_job_id = 0
    events = 
```

* Well, that's all!

Thumbnails generation
---------------------

* Install "imagemagick" on every irods resource

* Setup TMPDIR, THUMBNAIL_SIZE="608x608" and DEFAULT_RESOURCE="imag" into core.py

* Testing: create an empty sub-collection "thumbnails". Add a .jpg image. A reduced version of the image should be generated into "thumbnails"

* That's it !

