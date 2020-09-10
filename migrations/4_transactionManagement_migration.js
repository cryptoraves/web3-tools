const TransactionManagement = artifacts.require('TransactionManagement')
const AdminToolsLibrary = artifacts.require('AdminToolsLibrary')

const imgUrl = 'https://i.picsum.photos/id/99/200/200.jpg'
const originAddr = '0x0000000000000000000000000000000000000000'

const size = Buffer.byteLength(TransactionManagement.deployedBytecode, 'utf8') / 2;
console.log(size)

module.exports = function (deployer) {
  
  deployer.then(async () => {
  	await deployer.deploy(AdminToolsLibrary)
  	await deployer.link(AdminToolsLibrary, TransactionManagement)
    await deployer.deploy(TransactionManagement, imgUrl, originAddr, originAddr)
    const instance = await TransactionManagement.deployed()
        
    console.log('\n*************************************************************************\n')
    console.log('TransactionManagement Contract Address: '+instance.address)
    console.log('\n*************************************************************************\n')
  })
}