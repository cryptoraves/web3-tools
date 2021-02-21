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

if [[ -z $NETWORK ]]; then
	truffle migrate -f 10 --to 10
else
	truffle migrate -f 10 --to 10 --network $NETWORK
fi

rm ${HOME}/web3-tools/migrations/10_performance_migration.js