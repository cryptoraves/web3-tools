const ValidatorInterfaceContract = artifacts.require('ValidatorInterfaceContract')
const AdminToolsLibrary = artifacts.require('AdminToolsLibrary')

const imgUrl = 'https://i.picsum.photos/id/99/200/200.jpg'
const originAddr = '0x0000000000000000000000000000000000000000'

module.exports = function (deployer) {
  
  deployer.then(async () => {
  	
  	await deployer.deploy(AdminToolsLibrary)
  	await deployer.link(AdminToolsLibrary, ValidatorInterfaceContract)
    await deployer.deploy(ValidatorInterfaceContract, imgUrl, originAddr, originAddr)
    const instance = await ValidatorInterfaceContract.deployed()
        
    console.log('\n*************************************************************************\n')
    console.log('ValidatorInterfaceContract Address: '+instance.address)
    console.log('\n*************************************************************************\n')
  })
}
