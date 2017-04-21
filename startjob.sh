#!/bin/bash
 
#Fail if any line breaks
set -e 
#Print failed lines
set -x

#Get arguments
userdata=$1
userid=$2
jobtype=$3
route="pfioh-radiology-in-the-cloud.128.31.26.63.xip.io"
jobid=$userid-$(openssl rand -hex 12)
imageid="172.30.249.2:5000/radiology-in-the-cloud/sample-plugin"

#Do pfurly things
#pushpath
pfurl --verb POST --raw --http $route/api/v1/cmd --msg \
"{'action': 'pushPath',
    'meta': {
        'remote': {
            'path':         '/shared/$jobid'
        },
        'local': {
            'path':         '$userdata'
        },
        'transport': {
            'mechanism':    'compress',
            'compress': {
                'encoding': 'base64',
                'archive':  'zip',
                'unpack':   true,
                'cleanup':  true
            }
     }
}" --quiet --jsonprintindent 4


#Start job
#Create persistent volume, persistent volume claim, job object
oc create -f - <<EOF 
apiVersion: v1
kind: PersistentVolume
metadata:
    name: $jobid
spec:
    capacity:
        storage: 6Gi
    accessModes:
        - ReadWriteMany
    nfs:
        path: /exports/storage/$jobid
        server: ocp-master
    persistentVolumeReclaimPolicy: Retain
EOF

oc create -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
    name: $jobid
spec:
    accessModes:
    - ReadWriteOnce
    resources:
        requests:
            storage: 6Gi
    volumeName: $jobid
EOF

#Convert template to object, and pipe standard out to standard in to create
oc process -f ./job-template.yaml -v jobid=$jobid -v imageid=$imageid | oc create -f -

#Watch job
#oc observe $jobid 
while 1; do
    numactive=$(oc get job $imageid -o jsonpath='{.status.active}')
    if ((numactive>0)); then
        sleep 5
        continue
    fi
    break
done

numsucceeded=$(oc get job $imageid -o jsonpath='{.status.succeeded}')
numfailed=$(oc get job $imageid -o jsonpath='{.status.failed}')

if ((numsucceeded>0)); then
    #Download job results from purl/pfioh
    #pullpath
    pfurl --verb POST --raw --http $route/api/v1/cmd --msg \
    "{'action': 'pullPath',
        'meta': {
            'remote': {
                'path':         '/shared/$jobid'
            },
            'local': {
                'path':         '$userdata'
            },
            'transport': {
                'mechanism':    'compress',
                'compress': {
                    'encoding': 'base64',
                    'archive':  'zip',
                    'unpack':   true,
                    'cleanup':  true
                }
         }
    }" --quiet --jsonprintindent 4
fi

#Cleanup files
oc delete job $jobid 
oc delete pvc $jobid
oc delete pv $jobid