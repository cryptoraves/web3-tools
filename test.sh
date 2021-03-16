#!/bin/bash
function replaceAddressString(){
	EXTRACTEDSTR=$(echo $RES | cut -d' ' -f2 | cut -d"'" -f2)
	#echo $EXTRACTEDSTR
	NEWSTRING=$(echo "${RES/$EXTRACTEDSTR/$CONTRACTADDR}")
	#echo $NEWSTRING
	sed -i "s/$RES/$NEWSTRING/g" ~/cryptoraves-subgraph/subgraph.yaml
}
#get contract addresses generated from truffle migrate and stored at /tmp/contractAddresses.json
CONTRACTADDR=$(cat /tmp/contractAddresses.json | python3 -c "import sys, json; print(json.load(sys.stdin)['CryptoravesToken'])")
CONTRACTADDR=$(cat /tmp/contractAddresses.json | python3 -c "import sys, json; print(json.load(sys.stdin)['TokenManagement'])")
RES=$(grep "TokenManagementContractAddress1" ~/cryptoraves-subgraph/subgraph.yaml)
if [[ ! -z $RES ]]; then
	replaceAddressString
fi
CONTRACTADDR=$(cat /tmp/contractAddresses.json | python3 -c "import sys, json; print(json.load(sys.stdin)['UserManagement'])")
CONTRACTADDR=$(cat /tmp/contractAddresses.json | python3 -c "import sys, json; print(json.load(sys.stdin)['TransactionManagement'])")
RES=$(grep "TransactionManagementContractAddress1" ~/cryptoraves-subgraph/subgraph.yaml)
if [[ ! -z $RES ]]; then
	replaceAddressString
fi
CONTRACTADDR=$(cat /tmp/contractAddresses.json | python3 -c "import sys, json; print(json.load(sys.stdin)['ValidatorInterfaceContract'])")




