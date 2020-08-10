const WalletFull = artifacts.require('WalletFull')

module.exports = function (deployer) {
  
  deployer.then(async () => {

    await deployer.deploy(accounts[0])
    const instance = await WalletFull.deployed()
        
    console.log('\n*************************************************************************\n')
    console.log('WalletFull Address: '+instance.address)
    console.log('\n*************************************************************************\n')
  })
}