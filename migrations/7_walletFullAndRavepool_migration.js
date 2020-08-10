const Walletull = artifacts.require('WalletFull')

const ethers = require('ethers')

module.exports = function (deployer, network, accounts) {
  
  deployer.then(async () => {

    await deployer.deploy(accounts[0])
    const instance = await Walletull.deployed()
        
    console.log('\n*************************************************************************\n')
    console.log('Walletull Address: '+instance.address)
    console.log('\n*************************************************************************\n')
  })
}