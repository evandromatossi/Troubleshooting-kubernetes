#!/bin/bash
export IPDEV=`kubectl -n dev  get svc workshop-service  -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'`
export IPHML=`kubectl -n int  get svc workshop-service  -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'`
export IPPRO=`kubectl -n prod get svc workshop-service  -o=jsonpath='{.status.loadBalancer.ingress[0].ip}'`

while [ TRUE ]; do
clear

curl -XGET ${IPDEV} -o IPDEV.txt 2> /dev/null
curl -XGET ${IPHML} -o IPHML.txt 2> /dev/null
curl -XGET ${IPPRO} -o IPPRO.txt 2> /dev/null

echo "#########################################"
echo "Retorno no ambiente em DEV [${IPDEV}]:  "
cat IPDEV.txt
echo;echo

echo "#########################################"
echo "Retorno no ambiente em HML [${IPHML}]:  "
cat IPHML.txt
echo;echo

echo "#########################################"
echo "Retorno no ambiente em PROD [${IPPRO}]: "
cat IPPRO.txt
echo;echo

rm IPDEV.txt IPHML.txt IPPRO.txt
sleep 2

done
