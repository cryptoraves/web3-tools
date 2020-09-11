const TransactionManagement = artifacts.require('TransactionManagement')
const AdminToolsLibrary = artifacts.require('AdminToolsLibrary')

const size = Buffer.byteLength(TransactionManagement.deployedBytecode, 'utf8') / 2;
console.log(size)

module.exports = function (deployer) {
  
  deployer.then(async () => {
  	await deployer.deploy(AdminToolsLibrary)
  	await deployer.link(AdminToolsLibrary, TransactionManagement)

  	const tknMgmtInstance = await TokenManagement.deployed()
  	const usrMgmtInstance = await UserManagement.deployed()

    await deployer.deploy(TransactionManagement, imgUrl, tknMgmtInstance.address, usrMgmtInstance.address)
    const instance = await TransactionManagement.deployed()
        
    console.log('\n*************************************************************************\n')
    console.log('TransactionManagement Contract Address: '+instance.address)
    console.log('\n*************************************************************************\n')
  })
}