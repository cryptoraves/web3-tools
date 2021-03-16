const CryptoravesToken = artifacts.require('CryptoravesToken')

const imgUrl = 'https://i.picsum.photos/id/99/200/200.jpg'

const fs = require('fs');
const outputPath = '/tmp/contractAddresses.json'
try {
  fs.unlinkSync(outputPath)
} catch(e) {}

module.exports = function (deployer) {
  
  deployer.then(async () => {
    await deployer.deploy(CryptoravesToken, imgUrl)
    const instance = await CryptoravesToken.deployed()
        
    console.log('\n*************************************************************************\n')
    console.log('CryptoravesToken Contract Address: '+instance.address)
    console.log('\n*************************************************************************\n')

    await fs.appendFile(outputPath, '{"CryptoravesToken":"'+instance.address+'",', function (err) {
		if (err) throw err
	})
  })
}
