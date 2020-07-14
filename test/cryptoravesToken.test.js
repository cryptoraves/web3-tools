const CryptoravesToken = artifacts.require("CryptoravesToken");

const ERC20Full = artifacts.require('ERC20Full')
const ERC721Full = artifacts.require('ERC721Full')

let erc20, erc721

contract("CryptoravesToken", async accounts => {
  it("should Launch ERC20 & ERC721 contract", async () => {
    let erc20Instance = await ERC20Full.deployed()
    let erc721Instance = await ERC721Full.deployed()

    
    console.log(erc20Instance.address)
    console.log(erc721Instance.address)

    //let balance = await instance.getBalance.call(accounts[0]);
    //assert.equal(balance.valueOf(), 10000);
    //console.log(instance)
  })
})  
