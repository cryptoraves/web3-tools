const CryptoravesToken = artifacts.require("CryptoravesToken");

const ERC20Full = artifacts.require('ERC20Full')
const ERC721Full = artifacts.require('ERC721Full')

const ethers = require('ethers')

contract("CryptoravesToken", async accounts => {
  it("deposit ERC20", async () => {
  	let instance = await CryptoravesToken.deployed()
    let erc20Instance = await ERC20Full.deployed()
    	
    let appr = await erc20Instance.approve(
    	instance.address,
    	ethers.utils.parseUnits('987654321',18)
    )
    await instance.depositERC20(
    	ethers.utils.parseUnits('987654321',18), 
    	erc20Instance.address
    )

    let tokenId1155 = await instance.getManagedTokenIdByAddress(erc20Instance.address)
    let balance = await instance.balanceOf(accounts[0], tokenId1155)

    assert.equal(
    	balance.toString(),
    	ethers.utils.parseUnits('987654321',18).toString(),
    	'ERC20 balance does not match'
    )

  })
  it("deposit ERC721", async () => {
  	let instance = await CryptoravesToken.deployed()
    let erc721Instance = await ERC721Full.deployed()
console.log((await erc721Instance.balanceOf(accounts[0])).toString())
    let appr = await erc721Instance.approve(
    	instance.address,
    	0
    )
    await instance.depositERC721(
    	0,
    	erc721Instance.address
    )

    let tokenId1155 = await instance.getManagedTokenIdByAddress(erc721Instance.address)
    let balance = await instance.balanceOf(accounts[0], tokenId1155)
    console.log((await erc721Instance.balanceOf(accounts[0])).toString())
    console.log(balance.toString())
    assert.equal(
    	balance.toString(),
    	1,
    	'ERC721 balance does not match'
    )
  })
})  
