const path = require('path');
const fs = require('fs');
const solc = require('solc');

let buildDir = path.dirname(path.dirname(__dirname))+'/build/'
if (!fs.existsSync(buildDir)){
	//create build directory
	fs.mkdirSync(buildDir);
}


let contractsDir = path.dirname(__dirname)+'/contracts/'

fs.readdir(contractsDir, function(err, items) {

    for (var i=0; i<items.length; i++) {

    	var fullPath = contractsDir+items[i]
    	var stats = fs.statSync(fullPath)

    	if (stats.isDirectory()){
    		console.log(fullPath)
    	}
        //console.log(stats.isDirectory())
    }
});
//const helloPath = path.resolve(, 'contracts', 'hello.sol');
//const source = fs.readFileSync(helloPath, 'UTF-8');
//module.exports = solc.compile(source, 1).contracts[':Hello'];