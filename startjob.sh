#!/bin/bash
export KUBECONFIG=~/sa-kubeconfig.yaml

#Fail if any line breaks
set -e 
#Print failed lines
set -x

#Get arguments
userdata=$1
userid=$2
jobtype=$3
route=155.41.30.12:5055
#route="pfioh-radiology-in-the-cloud.128.31.26.63.xip.io"
jobid=$userid-$(openssl rand -hex 12)
imageid="172.30.249.2:5000/radiology-in-the-cloud/sample-plugin"

#pushpath
curl http://pfioh-radiology-in-the-cloud.128.31.26.63.xip.io/$jobid -F \
"filenames=somefile" -F "somefile=@"$userdata -v -X POST


#Start job
#Create persistent volume, persistent volume claim, job object
oc -n radiology-in-the-cloud create --namespace radiology-in-the-cloud -f - <<EOF 
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

oc -n radiology-in-the-cloud create --namespace radiology-in-the-cloud -f - <<EOF
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
oc -n radiology-in-the-cloud process --namespace radiology-in-the-cloud -f ./job-template.yaml -v jobid=$jobid -v imageid=$imageid | oc -n radiology-in-the-cloud create --namespace radiology-in-the-cloud -f -

#Watch job
#oc -n radiology-in-the-cloud observe $jobid 
while true; do
    numactive=$(oc -n radiology-in-the-cloud get job $jobid -o jsonpath='{.status.active}')
    if ((numactive>0)); then
        sleep 5
        continue
    fi
    break
done

numsucceeded=$(oc -n radiology-in-the-cloud get job $jobid -o jsonpath='{.status.succeeded}')
numfailed=$(oc -n radiology-in-the-cloud get job $jobid -o jsonpath='{.status.failed}')

if ((numsucceeded>0)); then
#Download job results from purl/pfioh
#pullpath
curl http://pfioh-radiology-in-the-cloud.128.31.26.63.xip.io/$jobid/somefile.out
fi

#Cleanup files
#oc -n radiology-in-the-cloud delete job $jobid 
#oc -n radiology-in-the-cloud delete pvc $jobid
#oc -n radiology-in-the-cloud delete pv $jobid
