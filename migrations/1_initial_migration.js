const Migrations = artifacts.require("Migrations");

const fs = require('fs');
const outputPath = '/tmp/contractAddresses.json'

try {
  fs.unlinkSync(outputPath)
  //file removed
} catch(err) {
  console.error(err)
}

module.exports = function(deployer) {
	deployer.deploy(Migrations);
	deployer.then(async () => {
		await fs.appendFile(outputPath, '{', function (err) {
		  if (err) throw err

		})
	})
};
