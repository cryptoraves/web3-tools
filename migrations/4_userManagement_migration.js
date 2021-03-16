const UserManagement = artifacts.require('UserManagement')
const TokenManagement = artifacts.require('TokenManagement')

const fs = require('fs');
const outputPath = '/tmp/contractAddresses.json'

module.exports = function (deployer) {
  
  deployer.then(async () => {
    await deployer.deploy(UserManagement)
    const instance = await UserManagement.deployed()
        
    console.log('\n*************************************************************************\n')
    console.log('UserManagement Contract Address: '+instance.address)
    console.log('\n*************************************************************************\n')

    await fs.appendFile(outputPath, '"UserManagement":"'+instance.address+'",', function (err) {
		if (err) throw err
	})
  })
}
