const WalletFull = artifacts.require('WalletFull')

module.exports = function (deployer, network, accounts) {
  
  deployer.then(async () => {
console.log(accounts[0])
    await deployer.deploy(accounts[0])
    const instance = await WalletFull.deployed()
        
    console.log('\n*************************************************************************\n')
    console.log('WalletFull Address: '+instance.address)
    console.log('\n*************************************************************************\n')
  })
}