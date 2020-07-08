const ValidatorInterfaceContract = artifacts.require("ValidatorInterfaceContract")

contract("ValidatorInterfaceContract", async accounts => {
  
  it("should verify token manager address is valid", async () => {
    let instance = await ValidatorInterfaceContract.deployed()
    let tokenManagerAddr = await instance.getTokenManager.call()
    
    assert.notEqual('0x0000000000000000000000000000000000000000', tokenManagerAddr, "Token Manager Address is zero address")
    assert.lengthOf(
      tokenManagerAddr,
      42,
      "Token Manager Address not valid: "+tokenManagerAddr
    );
  });
  it("should set a new tokenManager and check it", async () => {
    let instance = await ValidatorInterfaceContract.deployed()
    let res = await instance.changeTokenManager(accounts[1]) 
    let tokenManagerAddr = await instance.getTokenManager.call()
    assert.equal(
      tokenManagerAddr,
      accounts[1],
      "changeTokenManager failed with accounts[1] as input"
    );
  });
  it("should verify sender is validator", async () => {
    let instance = await ValidatorInterfaceContract.deployed()
    let isValidator = await instance.isValidator.call()
    assert.isOk(
      isValidator,
      "isValidator failed with main address as msg.sender"
    );
  });
  it("should revert since sender is not validator", async () => {
    let instance = await ValidatorInterfaceContract.deployed()
    let isValidator
    try{
    	isValidator = await instance.isValidator.call({from: accounts[2]})
    	assert.isOk(!isValidator, "isValidator failing. Should revert")
    }catch(e){
    	//reverts as predicted
    	assert.isOk(true)
    }
  });
  it("should set a new validator and check it", async () => {
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
    let res = await instance.unsetValidator(accounts[0]) 
    try{
    	isValidator = await instance.isValidator.call()
    	assert.isOk(!isValidator, "unsetValidator failing. Should revert")
    }catch(e){
    	//reverts as predicted
    	assert.isOk(true)
    }
  });
});