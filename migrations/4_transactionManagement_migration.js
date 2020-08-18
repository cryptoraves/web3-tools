const TransactionManagement = artifacts.require('TransactionManagement')

const imgUrl = 'https://i.picsum.photos/id/99/200/200.jpg'
const originAddr = '0x0000000000000000000000000000000000000000'

module.exports = function (deployer) {
  
  deployer.then(async () => {
    await deployer.deploy(TransactionManagement, imgUrl, originAddr, originAddr)
    const instance = await TransactionManagement.deployed()
        
    console.log('\n*************************************************************************\n')
    console.log('TransactionManagement Contract Address: '+instance.address)
    console.log('\n*************************************************************************\n')
  })
}