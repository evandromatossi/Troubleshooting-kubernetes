#!/bin/bash

###################################################################
#Script Name	:Cluster AKS BF                                                                                       
#Description	:                                                                                 
#Args           	:                                                                                           
#Author       	:SRE
#Version        : V8                                                                          
###################################################################

#set -x

#### Webhook do teams sre
WEBHOOK_URL="https://outlook.office.com/webhook/"

for loop in {1..10000}; do

##### validação cluster aks
function cluster_validacao_aks(){
    ##Colocar aqui o context do AKS
    for cluster in akspriv-pricing-prd-admin akspriv-viaunica-prd-admin akspriv-apicatalogo-prd-admin akspriv-bonificacao-prd-admin akspriv-descoberta-prd-admin akspriv-kong-prd-admin akspriv-meuspedidos-prd-admin ; do
      kubectx ${cluster}
      CLUSTER=$(kubectl config current-context)
      
      echo -e "##################################################################\n"
      echo -e "------------------------ Inicio da Validação do cluster aks '$cluster' ------------------------ "
      echo -e "------------------------ Informações da execução do script de validação no '$cluster' ------------------------ "
      echo "laço de repetição $loop em execução"
      echo "Hora e data da execução do script no cluster '$cluster'"
      date
      
      ###################### Validação de Erro dos PODs ##############################################################
      ERRO_POD=$(kubectl get pods -A | grep -v NAME  | awk '{print $4}'| grep -v Running )
      TEXT_POD="Existe um ERRO de '$ERRO_POD' no cluster '$CLUSTER'"
      # Convert format text teams.
      MESSAGE=$( echo ${TEXT_POD} | sed 's/"/\"/g' | sed "s/'/\'/g" )
      JSON_ERRO_POD="{\"title\": \"${CLUSTER}\",\"text\": \"${MESSAGE}\" }"
            
      if ["$ERRO_POD" == ""] 
      then
          echo -e "\n\n -------- Sem erro de pods no cluster '$cluster' -------- "
      else
          echo "'$TEXT_POD'"
          curl -H "Content-Type: application/json" -d "${JSON_ERRO_POD}" "${WEBHOOK_URL}"
      fi
      
      ###################### Validação de restart dos PODs ##############################################################
      ERRO_POD_RESTART=$(kubectl get pods -A | grep -v NAME | awk "{if(\$5>30) print \"\tNamespace: \"\$1,\"\tPod: \"\$2,\"\tRestart: \"\$5}" )
      TEXT_POD_RESTART="Existe um erro de pods reiniciadas acima de 30 vezes '$ERRO_POD_RESTART' no cluster '$CLUSTER'"
      # Convert format text teams.
      MESSAGE_POD_RESTART=$( echo ${TEXT_POD_RESTART} | sed 's/"/\"/g' | sed "s/'/\'/g" )
      JSON_POD_RESTART="{\"title\": \"${CLUSTER}\",\"text\": \"${MESSAGE_POD_RESTART}\" }" 
      
      echo -e "\n\n ----------------------- Pod com Restart. ----------------------- "
      if ["$ERRO_POD_RESTART" == ""]
      then
          echo -e "\n\n -------- Sem erro de pods restart no cluster '$cluster' -------- "
      else
          echo "Existe erro de pods reiniciadas acima de 30 vezes '$TEXT_POD_RESTART'"
          curl -H "Content-Type: application/json" -d "${JSON_POD_RESTART}" "${WEBHOOK_URL}"
      fi
      ###################### Validação de hpa minimo configurado ##############################################################
      
      echo -e "\n\n -------- HPA com mais pods do que o minimo configurado. -------- "
      ERRO_HPA=$(kubectl get hpa -A | grep -v NAME | awk "{if(\$7>\$5) print \"\tMinimo: \"\$5,\"\tMaximo: \"\$6,\"\tAtual: \"\$7,\"\tPorcentagem: \"\$4,\"\tDeployment: \"\$1}")
      TEXT_HPA="O minimo do hpa foi escalado '$ERRO_HPA' no cluster '$CLUSTER'"
      # Convert format text teams.
      MESSAGE_HPA=$( echo ${TEXT_HPA} | sed 's/"/\"/g' | sed "s/'/\'/g" )
      JSON_HPA="{\"title\": \"${CLUSTER}\",\"text\": \"${MESSAGE_HPA}\" }" 
           
      if ["$ERRO_HPA" == ""]
      then
          echo -e "\n\n -------- Sem HPA diferente do minimo configurado '$cluster' -------- "
      else
          echo "Existe HPA com mais pods do que o minimo '$TEXT_HPA'"
          curl -H "Content-Type: application/json" -d "${JSON_HPA}" "${WEBHOOK_URL}"
      fi
      
      
      ###################### Validação de Node diferente de Ready ##############################################################
      
      echo -e "\n\n ------------- Nodes com status diferente de Ready. ------------- "
      ERRO_NODE_READY=$(kubectl get nodes | grep -v NAME | grep -v Ready)
      TEXT_NODE_READY="O minimo do hpa foi escalado '$ERRO_NODE_READY' no cluster '$CLUSTER'"
      # Convert format text teams.
      MESSAGE_NODE_READY=$( echo ${TEXT_NODE_READY} | sed 's/"/\"/g' | sed "s/'/\'/g" )
      JSON_NODE_READY="{\"title\": \"${CLUSTER}\",\"text\": \"${MESSAGE_NODE_READY}\" }" 
      
      if ["$ERRO_NODE_READY" == ""]
      then
          echo -e "\n\n -------- Sem HPA diferente do minimo configurado '$cluster' -------- "
      else
          echo "Existe NODE diferente de Ready '$TEXT_NODE_READY'"
          curl -H "Content-Type: application/json" -d "${JSON_NOT_READY}" "${WEBHOOK_URL}"
      fi
           
      ###################### Validação de Node com o consumo do processador maior que 70% ##############################################################    
      
      echo -e "\n\n -------- Nodes com consumo de processador maior que 70%. ------- "
      ERRO_NODE_CPU=$(kubectl top nodes | grep -v "NAME\| 1%\| 2%\| 3%\| 4%\| 5%\| 6% \| 7%\| 8%\| 9%" | awk "{if(\$3 > 70) print \"\tCPU: \"\$3,\"\tName: \"\$1}")
      TEXT_NODE_CPU="Nodes com consumo de processador maior que 70% '$ERRO_NODE_CPU' no cluster '$CLUSTER'"
      # Convert format text teams.
      MESSAGE_NODE_CPU=$( echo ${TEXT_NODE_CPU} | sed 's/"/\"/g' | sed "s/'/\'/g" )
      JSON_NODE_CPU="{\"title\": \"${CLUSTER}\",\"text\": \"${MESSAGE_NODE_CPU}\" }" 
      
      if ["$ERRO_NODE_CPU" == ""]
      then
          echo -e "\n\n -------- O CPU estão dentro do esperado '$cluster' -------- "
      else
          echo "Existe alto consumo acima de 70% CPU '$TEXT_NODE_CPU'"
          curl -H "Content-Type: application/json" -d "${JSON_NODE_CPU}" "${WEBHOOK_URL}"
      fi

      ###################### Validação de Node com o consumo do memoria maior que 70% ##############################################################   
      
      echo -e "\n\n --------- Nodes com consumo de memória maior que 70%. ---------- "
      ERRO_NODE_MEM=$(kubectl top nodes | grep -v "NAME\| 1%\| 2%\| 3%\| 4%\| 5%\| 6% \| 7%\| 8%\| 9%" | awk "{if(\$5 > 70) print \"\tMEM: \"\$5,\"\tName: \"\$1}")
      TEXT_NODE_MEM="Nodes com consumo de memória maior que 70% '$ERRO_NODE_MEM' no cluster '$CLUSTER'"
      # Convert format text teams.
      MESSAGE_NODE_MEM=$( echo ${TEXT_NODE_MEM} | sed 's/"/\"/g' | sed "s/'/\'/g" )
      JSON_NODE_MEM="{\"title\": \"${CLUSTER}\",\"text\": \"${MESSAGE_NODE_MEM}\" }" 

      echo -e "\n\n ----------------------- Final da Validação do cluster aks '$cluster' ------------------------"
      echo -e "################################################################## \n\n"

    done

}

##### sleep para executar o proxima laço de repetição
function sleep_do_loop() {
    echo "### Aguardando o tempo de 10 minutos terminar para chamar a proxima validação ###"
    # Convert format text teams.
      TITULO="Validação dos cluster AKS finalizado com sucesso"
      MESSAGE_AGUARDE="Aguarde 10 minutos para o proximo teste no ambiente"
      MESSAGE_PROXIMO_TESTE=$( echo ${MESSAGE_AGUARDE} | sed 's/"/\"/g' | sed "s/'/\'/g" )
      JSON="{\"title\": \"${TITULO}\",\"text\": \"${MESSAGE_PROXIMO_TESTE}\" }"
      curl -H "Content-Type: application/json" -d "${JSON}" "${WEBHOOK_URL}"
    sleep 600
}

## Functions

cluster_validacao_aks
sleep_do_loop

done
