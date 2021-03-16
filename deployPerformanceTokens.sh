#!/bin/bash

while [ "$1" != "" ]; do
    case $1 in
        -n | --network )     
			shift
            NETWORK=$1
            ;;
       
    esac
    shift
done
cp 10_performance_migration.js ${HOME}/web3-tools/migrations/

#get contract addresses generated from truffle migrate and stored at /tmp/contractAddresses.json
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
RES=$(grep "UserManagementContractAddress1" ~/cryptoraves-subgraph/subgraph.yaml)
if [[ ! -z $RES ]]; then
	replaceAddressString
fi
CONTRACTADDR=$(cat /tmp/contractAddresses.json | python3 -c "import sys, json; print(json.load(sys.stdin)['TransactionManagement'])")
RES=$(grep "TransactionManagementContractAddress1" ~/cryptoraves-subgraph/subgraph.yaml)
if [[ ! -z $RES ]]; then
	replaceAddressString
fi
CONTRACTADDR=$(cat /tmp/contractAddresses.json | python3 -c "import sys, json; print(json.load(sys.stdin)['ValidatorInterfaceContract'])")



if [[ -z $NETWORK ]]; then
	truffle migrate -f 10 --to 10
else
	truffle migrate -f 10 --to 10 --network $NETWORK
fi

rm ${HOME}/web3-tools/migrations/10_performance_migration.js