const CryptoravesToken = artifacts.require('CryptoravesToken')

const imgUrl = 'https://i.picsum.photos/id/99/200/200.jpg'

module.exports = function (deployer) {
  
  deployer.then(async () => {
    await deployer.deploy(CryptoravesToken, imgUrl)
    const instance = await CryptoravesToken.deployed()
        
    console.log('\n*************************************************************************\n')
    console.log('CryptoravesToken Contract Address: '+instance.address)
    console.log('\n*************************************************************************\n')
  })
}
