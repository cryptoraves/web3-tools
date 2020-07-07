const UserManagement = artifacts.require('UserManagement')

module.exports = function (deployer) {
  
  deployer.then(async () => {
    await deployer.deploy(UserManagement)
    const instance = await UserManagement.deployed()
        
    console.log('\n*************************************************************************\n')
    console.log('UserManagement Contract Address: '+instance.address)
    console.log('\n*************************************************************************\n')
  })
}
