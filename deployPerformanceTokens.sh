#!/bin/bash

while [ "$1" != "" ]; do
    case $1 in
        -n | --network )     
			shift
            NETWORK=$1
            ;;
       
    esac
    case $1 in
        -b | --bypassMigration )     
			shift
            BYPASS=1
            ;;
       
    esac
    shift
done

DATAJSONPATH=/tmp/contractAddresses.json
YAMLPATH=~/cryptoraves-subgraph/subgraph.yaml
LAMBDACREDPATH=~/token-game/lambda-functions/skaleOracle/credentials.py

#get contract addresses generated from truffle migrate and stored at /tmp/contractAddresses.json
function replaceAddressStringYAML(){
	EXTRACTEDSTR=$(echo $RES | cut -d' ' -f2 | cut -d"'" -f2)
	#echo $EXTRACTEDSTR
	NEWSTRING=$(echo "${RES/$EXTRACTEDSTR/$CONTRACTADDR}")
	#echo $NEWSTRING
	sed -i "s/$RES/$NEWSTRING/g" $YAMLPATH
}
function replaceAddressStringLAMBDA(){
	EXTRACTEDSTR=$(echo $RES | cut -d' ' -f3 | cut -d"'" -f2)
	#echo $EXTRACTEDSTR
	NEWSTRING=$(echo "${RES/$EXTRACTEDSTR/$CONTRACTADDR}")
	#echo $NEWSTRING
	sed -i "s/$RES/$NEWSTRING/g" $LAMBDACREDPATH
}
#get contract addresses generated from truffle migrate and stored at /tmp/contractAddresses.json
CONTRACTADDR=$(cat ${DATAJSONPATH} | python3 -c "import sys, json; print(json.load(sys.stdin)['CryptoravesToken'])")
RES=$(grep "CryptoravesTokenContractAddress1" ${YAMLPATH})
if [[ ! -z $RES ]]; then
	replaceAddressStringYAML
fi
RES=$(grep "CryptoravesTokenContractAddress1localhost" ${LAMBDACREDPATH})
if [[ ! -z $RES ]]; then
	replaceAddressStringLAMBDA
fi
CONTRACTADDR=$(cat ${DATAJSONPATH} | python3 -c "import sys, json; print(json.load(sys.stdin)['TokenManagement'])")
RES=$(grep "TokenManagementContractAddress1" ${YAMLPATH})
if [[ ! -z $RES ]]; then
	replaceAddressStringYAML
fi
RES=$(grep "TokenManagementContractAddress1localhost" ${LAMBDACREDPATH})
if [[ ! -z $RES ]]; then
	replaceAddressStringLAMBDA
fi
CONTRACTADDR=$(cat ${DATAJSONPATH} | python3 -c "import sys, json; print(json.load(sys.stdin)['UserManagement'])")
RES=$(grep "UserManagementContractAddress1" ${YAMLPATH})
if [[ ! -z $RES ]]; then
	replaceAddressStringYAML
fi
RES=$(grep "UserManagementContractAddress1localhost" ${LAMBDACREDPATH})
if [[ ! -z $RES ]]; then
	replaceAddressStringLAMBDA
fi
CONTRACTADDR=$(cat ${DATAJSONPATH} | python3 -c "import sys, json; print(json.load(sys.stdin)['TransactionManagement'])")
RES=$(grep "TransactionManagementContractAddress1" ${YAMLPATH})
if [[ ! -z $RES ]]; then
	replaceAddressStringYAML
fi
RES=$(grep "TransactionManagementContractAddress1localhost" ${LAMBDACREDPATH})
if [[ ! -z $RES ]]; then
	replaceAddressStringLAMBDA
fi
CONTRACTADDR=$(cat ${DATAJSONPATH} | python3 -c "import sys, json; print(json.load(sys.stdin)['ValidatorInterfaceContract'])")
RES=$(grep "ValidatorInterfaceContractAddress1localhost" ${LAMBDACREDPATH})
if [[ ! -z $RES ]]; then
	replaceAddressStringLAMBDA
fi
CONTRACTADDR=$(cat ${DATAJSONPATH} | python3 -c "import sys, json; print(json.load(sys.stdin)['pubkey'])")
RES=$(grep "pubkey1localhost" ${LAMBDACREDPATH})
if [[ ! -z $RES ]]; then
	replaceAddressStringLAMBDA
fi

if [[ -z $BYPASS ]]; then

	cp 10_performance_migration.js ${HOME}/web3-tools/migrations/

	if [[ -z $NETWORK ]]; then
		truffle migrate -f 10 --to 10
	else
		truffle migrate -f 10 --to 10 --network $NETWORK
	fi

	rm ${HOME}/web3-tools/migrations/10_performance_migration.js
fi