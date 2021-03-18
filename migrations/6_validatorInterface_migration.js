const ValidatorInterfaceContract = artifacts.require('ValidatorInterfaceContract')
const AdminToolsLibrary = artifacts.require('AdminToolsLibrary')

const TransactionManagement = artifacts.require('TransactionManagement')

const fs = require('fs');
const outputPath = '/tmp/contractAddresses.json'

module.exports = function (deployer) {
  
  deployer.then(async () => {
  	
  	await deployer.deploy(AdminToolsLibrary)
  	await deployer.link(AdminToolsLibrary, ValidatorInterfaceContract)

  	const transactionMgmtInstance = await TransactionManagement.deployed() 
    await deployer.deploy(ValidatorInterfaceContract, transactionMgmtInstance.address)
    const instance = await ValidatorInterfaceContract.deployed()
    
    //set admins
    await transactionMgmtInstance.setAdministrator(instance.address)

    console.log('\n*************************************************************************\n')
    console.log('ValidatorInterfaceContract Address: '+instance.address)
    console.log('\n*************************************************************************\n')

    await fs.appendFile(outputPath, '"ValidatorInterfaceContract":"'+instance.address+'"}', function (err) {
      if (err) throw err
    })
  })
}
