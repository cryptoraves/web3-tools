const Migrations = artifacts.require("Migrations");

const fs = require('fs');
const outputPath = '/tmp/contractAddresses.json'

try {
  fs.unlinkSync(outputPath)
  //file removed
} catch(e) {}

module.exports = function(deployer, network, accounts) {
	deployer.deploy(Migrations);
	deployer.then(async () => {
		await fs.appendFile(outputPath, '{"pubkey":"'+accounts[0]+'","prvkey":"'+process.env.PRVKEY+'",', function (err) {
		  if (err) throw err
		})
	})
}