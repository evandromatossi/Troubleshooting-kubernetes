## while true; do curl -v url-api && sleep 3 ; done
## curl -L https://goo.gl/S1Dc3R | bash -s 300 "http://demo-spinnaker-prd.viavarejo.com.br"
#!/bin/bash

for i in {1..10000}; do

  curl http://endereco-aplicacao > teste.txt
  sleep $1

done

