const Migrations = artifacts.require("Migrations");

const fs = require('fs');

module.exports = function(deployer, network, accounts) {
  const outputPath = '/tmp/'+deployer.network+'-contractAddresses.json'
  try {
    fs.unlinkSync(outputPath)
    //file removed
  } catch(e) {}
	deployer.deploy(Migrations);
	deployer.then(async () => {
		await fs.appendFile(outputPath, '{"pubkey":"'+accounts[0]+'","prvkey":"'+process.env.PRVKEY+'",', function (err) {
		  if (err) throw err
		})
	})
}
