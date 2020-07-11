const TokenManagement = artifacts.require('TokenManagement')

const imgUrl = 'https://i.picsum.photos/id/99/200/200.jpg'
const originAddr = '0x0000000000000000000000000000000000000000'

module.exports = function (deployer) {
  
  deployer.then(async () => {
    await deployer.deploy(TokenManagement, imgUrl, originAddr, originAddr)
    const instance = await TokenManagement.deployed()
        
    console.log('\n*************************************************************************\n')
    console.log('TokenManagement Contract Address: '+instance.address)
    console.log('\n*************************************************************************\n')
  })
}