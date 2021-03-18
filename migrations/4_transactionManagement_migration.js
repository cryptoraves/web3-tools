const TransactionManagement = artifacts.require('TransactionManagement')
const AdminToolsLibrary = artifacts.require('AdminToolsLibrary')

const TokenManagement = artifacts.require('TokenManagement')
const UserManagement = artifacts.require('UserManagement')

const fs = require('fs');
const outputPath = '/tmp/contractAddresses.json'

module.exports = function (deployer) {
  
  deployer.then(async () => {
  	await deployer.deploy(AdminToolsLibrary)
  	await deployer.link(AdminToolsLibrary, TransactionManagement)

  	const tknMgmtInstance = await TokenManagement.deployed()
  	const usrMgmtInstance = await UserManagement.deployed()

    await deployer.deploy(TransactionManagement, tknMgmtInstance.address, usrMgmtInstance.address)
    const instance = await TransactionManagement.deployed()

    await tknMgmtInstance.setAdministrator(instance.address)
    await usrMgmtInstance.setAdministrator(instance.address)
        
    console.log('\n*************************************************************************\n')
    console.log('TransactionManagement Contract Address: '+instance.address)
    console.log('\n*************************************************************************\n')

    await fs.appendFile(outputPath, '"TransactionManagement":"'+instance.address+'",', function (err) {
      if (err) throw err
    })
  })
}