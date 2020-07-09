const TokenManagement = artifacts.require("TokenManagement");

const ethers = require('ethers')

contract("TokenManagement", async accounts => {
  it("verify cryptoraves token address is valid", async () => {
    let instance = await TokenManagement.deployed()
    let tokenContractAddr = await instance.getCryptoravesTokenAddress.call()
    
    assert.notEqual('0x0000000000000000000000000000000000000000', tokenContractAddr, "Token Manager Address is zero address")
    assert.lengthOf(
      tokenContractAddr,
      42,
      "Token cryptoraves token Address not valid: "+tokenContractAddr
    )
  })
  it("Drop crypto with initCommand", async () => {
    let instance = await TokenManagement.deployed()
	var bytes = ethers.utils.formatBytes32String('testing crypto drop')
    let res = await instance.initCommand(
    	[1029384756,0,0],
    	['@fakeHandleA', '', ''],
    	'https://i.picsum.photos/id/111/200/200.jpg',
    	true,
    	0,
    	bytes
    )
    //for next test
    res = await instance.initCommand(
    	[1029388888,0,0],
    	['@fakeHandleB', '', ''],
    	'https://i.picsum.photos/id/111/201/200.jpg',
    	true,
    	0,
    	bytes
    )
    assert.isOk(res.receipt['status'])
  })
  it("get token from twitter id", async () => {
    let instance = await TokenManagement.deployed()
    let tokenId = await instance.getTokenIdFromPlatformId.call(1029388888)
//WARNING Zero is returned if no tokenId exists. Must fix??
    assert.isAbove(
      tokenId.toNumber(),
      0,
      "Token ID not valid: "+tokenId.toNumber()
    )
  })

  	/*
	* Begin UserManager Portion
	*/
  it("get token from twitter id", async () => {
    let instance = await TokenManagement.deployed()
    let tokenId = await instance.getTokenIdFromPlatformId.call(18)
    assert.isNumber(
      tokenId.toNumber(),
      "Token ID not valid: "+tokenId.toNumber()
    )
  })	
})  