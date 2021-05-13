## while true; do curl -v http://recovery-api-cb.ocp-eqx.dc.nova/api/about && sleep 5 ; done
#!/bin/bash

for i in {1..10000}; do

  curl http://endereco-aplicacao > teste.txt
  sleep $1

done

