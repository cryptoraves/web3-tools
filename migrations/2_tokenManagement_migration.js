const TokenManagement = artifacts.require('TokenManagement')

const imgUrl = 'https://i.picsum.photos/id/99/200/200.jpg'
const fs = require('fs');
const outputPath = '/tmp/contractAddresses.json'

module.exports = function (deployer) {
  
  deployer.then(async () => {
    await deployer.deploy(TokenManagement, imgUrl)
    const instance = await TokenManagement.deployed()

    let CryptoravesTokenAddress = await instance.getCryptoravesTokenAddress()

    console.log('\n*************************************************************************\n')
    console.log('CryptoravesToken Contract Address: '+CryptoravesTokenAddress)
    console.log('\n*************************************************************************\n')
    await fs.appendFile(outputPath, '"CryptoravesToken":"'+CryptoravesTokenAddress+'",', function (err) {
      if (err) throw err
    })
      
    console.log('\n*************************************************************************\n')
    console.log('TokenManagement Contract Address: '+instance.address)
    console.log('\n*************************************************************************\n')

    await fs.appendFile(outputPath, '"TokenManagement":"'+instance.address+'",', function (err) {
  		if (err) throw err
  	})
  })
}
