#!/bin/sh

###
# Date        : 2020-10-25 15:49:41
# Author      : shy
# Email       : yushuibo@ebupt.com / hengchen2005@gmail.com
# Version     : v1.0
# Description : -
###

#!/bin/bash
set -e
KUBE_VERSION=v1.18.8
KUBE_DASHBOARD_VERSION=v1.10.1
KUBE_PAUSE_VERSION=3.2
ETCD_VERSION=3.4.3
COREDNS_VERSION=1.6.7
# 这里为了使国内拉取镜像更快，使用了mirrorgooglecontainers进行拉取
GCR_URL=mirrorgooglecontainers
#GCR_URL=k8s.gcr.io
ALIYUN_URL=2gk4bdl6.mirror.aliyuncs.com/google_containers
#get images
images=(kube-proxy:${KUBE_VERSION}
kube-scheduler:${KUBE_VERSION}
kube-controller-manager:${KUBE_VERSION}
kube-apiserver:${KUBE_VERSION}
pause:${KUBE_PAUSE_VERSION}
etcd:${ETCD_VERSION}
coredns:${COREDNS_VERSION}
kubernetes-dashboard-amd64:${KUBE_DASHBOARD_VERSION})
for imageName in ${images[@]} ; do
docker pull $ALIYUN_URL/$imageName
docker tag $ALIYUN_URL/$imageName $GCR_URL/$imageName
docker rmi $ALIYUN_URL/$imageName
done
docker images
