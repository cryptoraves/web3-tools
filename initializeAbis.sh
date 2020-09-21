#!/bin/bash
relPath=$(dirname $(realpath $0))/build/contracts/*
# keep in alphabetical order
contractJsons=('CryptoravesToken', 'TokenManagement', 'TransactionManagement', 'UserManagement', 'ValidatorInterfaceContract')

echo 'const abis = { ' > ./pages/abis.js
for f in $relPath
do
	FILENAME=$(basename $f)
	FILENAME=${FILENAME%.*}
  	if [[ "${contractJsons[*]}" == *"$FILENAME"* ]]; then
  		echo "\"${FILENAME%.*}\": {" >> ./pages/abis.js
	  	ABI="$(cat ${f} | python3 -c "import sys, json; print(json.load(sys.stdin)['abi'])")"
		if [[ "$ABI" != *"KeyError:"* ]]; then
			echo "\"abi\":\"$ABI\",">> ./pages/abis.js
		fi
		BYTECODE="$(cat ${f} | python3 -c "import sys, json; print(json.load(sys.stdin)['bytecode'])")"
		if [[ "$BYTECODE" != *"KeyError:"* ]]; then
			echo "\"bytecode\":\"$BYTECODE\"" >> ./pages/abis.js
		fi
		if [[ "ValidatorInterfaceContract" == "${FILENAME}" ]]; then
			echo '}' >> ./pages/abis.js
		else
			echo '},' >> ./pages/abis.js
		fi
		
	fi
done
echo '}' >> ./pages/abis.js
