const ERC20Full = artifacts.require('ERC20Full')
const ERC721Full = artifacts.require('ERC721Full')

const ethers = require('ethers')

module.exports = function (deployer, network, accounts) {
  
  deployer.then(async () => {

    await deployer.deploy(ERC20Full, accounts[0], 'TokenX', 'TKX', 18, ethers.utils.parseUnits('1000000000',18))
    const instance = await ERC20Full.deployed()
        
    console.log('\n*************************************************************************\n')
    console.log('ERC20 Address: '+instance.address)
    console.log('\n*************************************************************************\n')
  })

  deployer.then(async () => {
  	
    await deployer.deploy(ERC721Full, accounts[0], 'TokenY', 'TKY')
    const instance = await ERC721Full.deployed()
        
    console.log('\n*************************************************************************\n')
    console.log('ERC721 Address: '+instance.address)
    console.log('\n*************************************************************************\n')
  })
  
}
