const UserManagement = artifacts.require('UserManagement')
const TokenManagement = artifacts.require('TokenManagement')

module.exports = function (deployer) {
  
  deployer.then(async () => {
    await deployer.deploy(UserManagement, TokenManagement.address)
    const instance = await UserManagement.deployed()
        
    console.log('\n*************************************************************************\n')
    console.log('UserManagement Contract Address: '+instance.address)
    console.log('\n*************************************************************************\n')
  })
}
