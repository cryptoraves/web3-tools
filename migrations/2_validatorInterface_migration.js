const ValidatorInterfaceContract = artifacts.require('ValidatorInterfaceContract')

const imgUrl = 'https://i.picsum.photos/id/99/200/200.jpg'
const originAddr = '0x0000000000000000000000000000000000000000'

module.exports = function (deployer, network, accounts) {
  
  deployer.then(async () => {
    console.log(ValidatorInterfaceContract)
    await deployer.deploy(ValidatorInterfaceContract, imgUrl, originAddr)
    const instance = await ValidatorInterfaceContract.deployed()
        
    console.log('\n*************************************************************************\n')
    console.log('ValidatorInterfaceContract Contract Address: '+instance.address)
    console.log('\n*************************************************************************\n')
  })
}
