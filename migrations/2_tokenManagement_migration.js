const TokenManagement = artifacts.require('TokenManagement')

const imgUrl = 'https://i.picsum.photos/id/99/200/200.jpg'
const fs = require('fs');
let CryptoravesTokenAddress =''

module.exports = function (deployer) {
  const outputPath = '/tmp/'+deployer.network+'-contractAddresses.json'

  deployer.then(async () => {
    await deployer.deploy(TokenManagement, imgUrl)
    const instance = await TokenManagement.deployed()

    CryptoravesTokenAddress = await instance.cryptoravesTokenAddr()

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
  }).then(async () => {
    let TokenManagementJson = require('../build/contracts/TokenManagement.json');
    let CryptoravesTokenJson = require('../build/contracts/CryptoravesToken.json');

    //add cryptoraves address to its json filter_level
    let network_id = deployer.network_id.toString()
    let networksElement = {}
    networksElement[network_id] = { 'address':CryptoravesTokenAddress }

    CryptoravesTokenJson['networks']=networksElement
    try {
      await fs.writeFileSync('build/contracts/CryptoravesToken.json', JSON.stringify(CryptoravesTokenJson))

    } catch (err) {
      console.error(err)
    }

  })

}
