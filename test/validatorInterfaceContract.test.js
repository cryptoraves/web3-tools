const ValidatorInterfaceContract = artifacts.require("ValidatorInterfaceContract")

const TransactionManagement = artifacts.require("TransactionManagement");
const TokenManagement = artifacts.require("TokenManagement");
const UserManagement = artifacts.require("UserManagement");

const ethers = require('ethers')

let secondTokenManagerAddr = ''
let ids = []
let amounts = []
let primaryUserId = 38845343252

contract("ValidatorInterfaceContract", async accounts => {
  
  //for iterateing through second token contract assignment
  for (var i = 0; i < 2; i++) {  
    it("Drop crypto", async () => {
      let instance = await ValidatorInterfaceContract.deployed()
      var bytes = ethers.utils.formatBytes32String('')
      let res = await instance.validateCommand(
      	[primaryUserId,0,0],
      	['@fakeHandle', '', ''],
      	['twitter','https://i.picsum.photos/id/1/200/200.jpg','launch', bytes],
      	0
      )
      assert.isOk(res);
    });
    it("Transfer dropped crypto", async () => {
      let instance = await ValidatorInterfaceContract.deployed()
  	  var bytes = ethers.utils.formatBytes32String('')
      let res = await instance.validateCommand(
      	[primaryUserId,434443434,0],
      	['@fakeHandle', '@rando1', ''],
      	['twitter','https://i.picsum.photos/id/1/200/200.jpg','transfer', bytes],
      	200
      )
      assert.isOk(res.receipt['status']);
    });
    it("Transfer 3rd party crypto", async () => {
      let instance = await ValidatorInterfaceContract.deployed()
      var bytes = ethers.utils.formatBytes32String('')
      let res = await instance.validateCommand(
      	[434443434,55667788,0],
      	['@rando1', '@rando2', ''],
      	['twitter','https://i.picsum.photos/id/2/200/200.jpg','transfer', bytes],
      	50
      )
      assert.isOk(res.receipt['status']);
      res = await instance.validateCommand(
      	[434443434,primaryUserId,0],
      	['@rando1', '@rando2', ''],
      	['twitter','https://i.picsum.photos/id/2/200/200.jpg','transfer', bytes],
        50
      )
      assert.isOk(res.receipt['status']);
    });
    it("verify transaction manager address is valid", async () => {
      let instance = await ValidatorInterfaceContract.deployed()
      let txnManagerAddr = await instance.getTransactionManagementAddress()
      
      assert.notEqual('0x0000000000000000000000000000000000000000', txnManagerAddr, "Token Manager Address is zero address")
      assert.lengthOf(
        txnManagerAddr,
        42,
        "Token Manager Address not valid: "+txnManagerAddr
      );
    });

    it("get held token balances", async () => {
      let instance = await ValidatorInterfaceContract.deployed()

      let instanceTransactionManagement = await TransactionManagement.at(
        await instance.getTransactionManagementAddress()
      )
      let instanceTokenManagement = await TokenManagement.at(
        await instanceTransactionManagement.getTokenManagementAddress()
      )
      let instanceUserManagement = await UserManagement.at(
        await instanceTransactionManagement.getUserManagementAddress()
      )
      
      //generate dummy data
      let randoAddr = ''
      let bytes = ethers.utils.formatBytes32String('')
      for(i=0; i < 5; i++){
        ids[i] = getRandomInt(100000000, 200000000)
        let rInt = getRandomInt(1, 999999999).toString()+'.0'

        amounts[i] = ethers.utils.parseUnits(rInt,18)
        let uri = 'https://i.picsum.photos/id/'+ids[i].toString()+'/200/200.jpg'
        await instance.validateCommand([ids[i],0,0], ['@rando'+ids[i].toString(), '', ''], ['twitter',uri,'launch', bytes], 0)
        await instance.validateCommand([ids[i],primaryUserId,0], ['@rando'+ids[i].toString(), '@fakeHandle', ''], ['twitter',uri,'transfer', bytes], amounts[i])
      }
      let primaryUserAccount = await instanceUserManagement.getUserAccount(primaryUserId)
      let heldIds = await instanceTokenManagement.getHeldTokenIds(
        primaryUserAccount
      )
      assert.isAbove(heldIds.length, 0, 'No held token ids returned.')
      let tokenId, userAddr;
      for(i=0; i < 5; i++){
        userAddr = await instanceUserManagement.getUserAccount(ids[i])
        tokenId = await instanceTokenManagement.getManagedTokenIdByAddress(userAddr)
        switch(i){
          case 0: assert.equal(tokenId.toString(), heldIds[i+1].toString(), 'heldid corresponding to id0 does not match'); break;
          case 1: assert.equal(tokenId.toString(), heldIds[i+1].toString(), 'heldid corresponding to id1 does not match'); break;
          case 2: assert.equal(tokenId.toString(), heldIds[i+1].toString(), 'heldid corresponding to id2 does not match'); break;
          case 3: assert.equal(tokenId.toString(), heldIds[i+1].toString(), 'heldid corresponding to id3 does not match'); break;
          case 4: assert.equal(tokenId.toString(), heldIds[i+1].toString(), 'heldid corresponding to id4 does not match'); break;
          
        }
      }
      let balances = await instanceTokenManagement.getHeldTokenBalances(primaryUserAccount)
      assert.isAbove(balances.length, 0, 'No held token ids returned.')
      for(i=0; i < balances.length; i++){
        switch(i){
          case 0: assert.equal(amounts[i].toString(), balances[i+1].toString(), 'transferred balance0 does not match'); break;
          case 1: assert.equal(amounts[i].toString(), balances[i+1].toString(), 'transferred balance1 does not match'); break;
          case 2: assert.equal(amounts[i].toString(), balances[i+1].toString(), 'transferred balance2 does not match'); break;
          case 3: assert.equal(amounts[i].toString(), balances[i+1].toString(), 'transferred balance3 does not match'); break;
          case 4: assert.equal(amounts[i].toString(), balances[i+1].toString(), 'transferred balance4 does not match'); break;

        }
      }
    })
    it("set a new transactionManager and check it", async () => {
      let instance = await ValidatorInterfaceContract.deployed()

      if(secondTokenManagerAddr==''){
        let txnMgmt = await TransactionManagement.deployed()
        await txnMgmt.setAdministrator(instance.address)
        secondTokenManagerAddr = txnMgmt.address
      }else{
        secondTokenManagerAddr = ethers.Wallet.createRandom().address
      }

      let res = await instance.changeTransactionManagementAddress(secondTokenManagerAddr) 
      let transactionManagerAddr = await instance.getTransactionManagementAddress()
      assert.equal(
        transactionManagerAddr,
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
      let isValidator = await instance.isAdministrator.call({ from: wallet.address })
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
function getRandomInt(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1)) + min;
}
