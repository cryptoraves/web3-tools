const ValidatorInterfaceContract = artifacts.require("ValidatorInterfaceContract")


const truffleAssert = require('truffle-assertions');
const ethers = require('ethers')
contract("ValidatorInterfaceContract", async accounts => {
  
  it("Drop crypto", async () => {
    let instance = await ValidatorInterfaceContract.deployed()
	var bytes = ethers.utils.formatBytes32String('')
    let res = await instance.validateCommand(
    	[38845343252,0,0],
    	['@fakeHandle', '', ''],
    	'https://i.picsum.photos/id/1/200/200.jpg',
    	true,
    	0,
    	bytes
    )
    assert.isOk(res);
  });
  it("Transfer dropped crypto", async () => {
    let instance = await ValidatorInterfaceContract.deployed()
	var bytes = ethers.utils.formatBytes32String('')
    let res = await instance.validateCommand(
    	[38845343252,434443434,0],
    	['@fakeHandle', '@rando1', ''],
    	'https://i.picsum.photos/id/1/200/200.jpg',
    	false,
    	200,
    	bytes
    )
    assert.isOk(res.receipt['status']);
  });
  it("Transfer 3rd party crypto", async () => {
    let instance = await ValidatorInterfaceContract.deployed()
	var bytes = ethers.utils.formatBytes32String('')
    let res = await instance.validateCommand(
    	[434443434,55667788,0],
    	['@rando1', '@rando2', ''],
    	'https://i.picsum.photos/id/2/200/200.jpg',
    	false,
    	50,
    	bytes
    )
    assert.isOk(res.receipt['status']);
    res = await instance.validateCommand(
    	[434443434,38845343252,0],
    	['@rando1', '@rando2', ''],
    	'https://i.picsum.photos/id/2/200/200.jpg',
    	false,
    	50,
    	bytes
    )
    assert.isOk(res.receipt['status']);
  });
  it("verify token manager address is valid", async () => {
    let instance = await ValidatorInterfaceContract.deployed()
    let tokenManagerAddr = await instance.getTokenManager.call()
    
    assert.notEqual('0x0000000000000000000000000000000000000000', tokenManagerAddr, "Token Manager Address is zero address")
    assert.lengthOf(
      tokenManagerAddr,
      42,
      "Token Manager Address not valid: "+tokenManagerAddr
    );
  });
  it("set a new tokenManager and check it", async () => {
    let instance = await ValidatorInterfaceContract.deployed()
    let res = await instance.changeTokenManager(accounts[1]) 
    let tokenManagerAddr = await instance.getTokenManager.call()
    assert.equal(
      tokenManagerAddr,
      accounts[1],
      "changeTokenManager failed with accounts[1] as input"
    );
  });
  it("verify sender is validator", async () => {
    let instance = await ValidatorInterfaceContract.deployed()
    let isValidator = await instance.isValidator.call()
    assert.isOk(
      isValidator,
      "isValidator failed with main address as msg.sender"
    );
  });
  it("revert since sender is not validator", async () => {
    let instance = await ValidatorInterfaceContract.deployed()
    let isValidator
    try{
    	isValidator = await instance.isValidator.call({from: accounts[2]})
    	assert.isOk(!isValidator, "isValidator failing. revert")
    }catch(e){
    	//reverts as predicted
    	assert.isOk(true)
    }
  });
  it("set a new validator and check it", async () => {
    let instance = await ValidatorInterfaceContract.deployed()
    let res = await instance.setValidator(accounts[1]) 
    let isValidator = await instance.isValidator.call({ from: accounts[1] })
    assert.isOk(
      isValidator,
      "isValidator failed with accounts[1] as msg.sender"
    );
  });
  it("should UNSET a new validator and check it", async () => {
    let instance = await ValidatorInterfaceContract.deployed()
    let res = await instance.setValidator(accounts[1]) 
    assert.isOk(res)
    res = await instance.unsetValidator(accounts[1]) 
    
    try{
    	isValidator = await instance.isValidator.call({ from: accounts[1] })
    	assert.isOk(!isValidator, "unsetValidator failing. Should revert")
    }catch(e){
    	//reverts as predicted
    	assert.isOk(true)
    }
  });

});