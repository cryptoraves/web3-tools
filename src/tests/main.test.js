const path = require('path');
const fs = require('fs');
const solc = require('solc');


let buildDir = path.dirname(path.dirname(__dirname))+'/build/'
if (!fs.existsSync(buildDir)){
	//create build directory
	fs.mkdirSync(buildDir);
}

let contractsDir = path.dirname(__dirname)+'/contracts'

readDirectory(contractsDir)

function readDirectory (dirname) {
	fs.readdir(dirname, function(err, items) {

	    for (var i=0; i<items.length; i++) {

	    	var fullPathToItem = dirname+'/'+items[i]
	    	var contractPathStats = fs.statSync(fullPathToItem)

	    	var buildFolderName = fullPathToItem.split(path.sep).pop()
	    	var fullPathToItemBuildFolder = buildDir+buildFolderName
	    	
	    	if (contractPathStats.isDirectory()){

	    		//create dir in build folder
	    		if (!fs.existsSync(fullPathToItemBuildFolder)){
					//create build directory
					fs.mkdirSync(fullPathToItemBuildFolder);
				}
	    		readDirectory(fullPathToItem)
	    		
	    	} else {
	    		var source = fs.readFileSync(fullPathToItem, 'UTF-8');

	    		var input = {
				  language: 'Solidity',
				  sources: {
				    fullPathToItem : {
				      content: source
				    }
				  },
				  settings: {
				    outputSelection: {
				      '*': {
				        '*': ['*']
				      }
				    }
				  }
				};
				
	    		console.log(JSON.parse(solc.compile(JSON.stringify(input))))
	    		
	    	}
	    }
	});
}
//const helloPath = path.resolve(, 'contracts', 'hello.sol');
//const source = fs.readFileSync(helloPath, 'UTF-8');
//module.exports = solc.compile(source, 1).contracts[':Hello'];