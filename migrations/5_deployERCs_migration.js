const ERC20Full = artifacts.require('ERC20Full')
const ERC721Full = artifacts.require('ERC721Full')

const ethers = require('ethers')

const fs = require('fs');
const outputPath = '/tmp/contractAddresses.json'

module.exports = function (deployer, network, accounts) {
  
  deployer.then(async () => {

    await deployer.deploy(ERC20Full, accounts[0], 'TokenX', 'TKX', 18, ethers.utils.parseUnits('1000000000',18))
    const instance = await ERC20Full.deployed()
        
    console.log('\n*************************************************************************\n')
    console.log('ERC20 Address: '+instance.address)
    console.log('\n*************************************************************************\n')

    await fs.appendFile(outputPath, '"ERC20Full":"'+instance.address+'",', function (err) {
      if (err) throw err
    })
  })

  deployer.then(async () => {
  	
    await deployer.deploy(ERC721Full, accounts[0], 'TokenY', 'TKY','https://source.unsplash.com/random/300x200?sig=0')
    const instance = await ERC721Full.deployed()
        
    console.log('\n*************************************************************************\n')
    console.log('ERC721 Address: '+instance.address)
    console.log('\n*************************************************************************\n')

    await fs.appendFile(outputPath, '"ERC721Full":"'+instance.address+'",', function (err) {
      if (err) throw err
    })
  })
  
}
