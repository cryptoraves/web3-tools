const ValidatorInterfaceContract = artifacts.require("ValidatorInterfaceContract")

const ethers = require('ethers')

const TokenManagement = artifacts.require("TokenManagement");
let secondTokenManagerAddr = ''

contract("ValidatorInterfaceContract", async accounts => {
  
  //for iterateing through second token contract assignment
  for (var i = 0; i < 2; i++) {  
    

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

      if(secondTokenManagerAddr==''){
        let tknMgmt = await TokenManagement.deployed()
        await tknMgmt.setAdministrator(instance.address)
        secondTokenManagerAddr = tknMgmt.address
      }else{
        secondTokenManagerAddr = ethers.Wallet.createRandom().address
      }

      let res = await instance.changeTokenManager(secondTokenManagerAddr) 
      let tokenManagerAddr = await instance.getTokenManager.call()
      assert.equal(
        tokenManagerAddr,
        secondTokenManagerAddr,
        "changeTokenManager failed with random wallet.address as input"
      );
    });
  }
    it("verify sender is admin", async () => {
      let instance = await ValidatorInterfaceContract.deployed()
      let isValidator = await instance.isAdministrator.call()
      assert.isOk(
        isValidator,
        "isValidator failed with main address as msg.sender"
      );
    });
    it("revert since different sender is not admin", async () => {
      let instance = await ValidatorInterfaceContract.deployed()
      let isValidator
      try{
      	isValidator = await instance.isAdministrator.call({from: ethers.Wallet.createRandom().address})
      	assert.isOk(!isValidator, "isAdmin failing. revert")
      }catch(e){
      	//reverts as predicted
      	assert.isOk(true)
      }
    });
    it("set a new administrator and check it", async () => {
      let instance = await ValidatorInterfaceContract.deployed()

      let wallet = ethers.Wallet.createRandom()

      let res = await instance.setAdministrator(wallet.address) 
      let isValidator = await instance.isAdministrator.call({ from: wallet.address] })
      assert.isOk(
        isValidator,
        "isValidator failed with random wallet.address as msg.sender"
      );
    });
    it("should UNSET a new administrator and check it", async () => {
      let instance = await ValidatorInterfaceContract.deployed()

      let wallet = ethers.Wallet.createRandom()

      let res = await instance.setAdministrator(wallet.address) 
      assert.isOk(res)
      res = await instance.unsetAdministrator(wallet.address) 
      
      try{
      	isValidator = await instance.isAdministrator.call({ from: wallet.address })
      	assert.isOk(!isValidator, "unsetValidator failing. Should revert")
      }catch(e){
      	//reverts as predicted
      	assert.isOk(true)
      }
    });

});