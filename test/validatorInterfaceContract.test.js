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
      	'https://i.picsum.photos/id/1/200/200.jpg',
      	'launch',
      	0,
      	bytes
      )
      assert.isOk(res);
    });
    it("Transfer dropped crypto", async () => {
      let instance = await ValidatorInterfaceContract.deployed()
  	var bytes = ethers.utils.formatBytes32String('')
      let res = await instance.validateCommand(
      	[primaryUserId,434443434,0],
      	['@fakeHandle', '@rando1', ''],
      	'https://i.picsum.photos/id/1/200/200.jpg',
      	'transfer',
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
      	'transfer',
      	50,
      	bytes
      )
      assert.isOk(res.receipt['status']);
      res = await instance.validateCommand(
      	[434443434,primaryUserId,0],
      	['@rando1', '@rando2', ''],
      	'https://i.picsum.photos/id/2/200/200.jpg',
      	'transfer',
      	50,
      	bytes
      )
      assert.isOk(res.receipt['status']);
    });
    it("verify transaction manager address is valid", async () => {
      let instance = await ValidatorInterfaceContract.deployed()
      let txnManagerAddr = await instance.getTransactionManager()
      
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
        await instance.getTransactionManager()
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
        amounts[i] = getRandomInt(1, 999999999)
        let uri = 'https://i.picsum.photos/id/'+ids[i].toString()+'/200/200.jpg'
        await instance.validateCommand([ids[i],0,0], ['@rando'+ids[i].toString(), '', ''], uri, 'launch', 0, bytes)
        await instance.validateCommand([ids[i],primaryUserId,0], ['@rando'+ids[i].toString(), '@fakeHandle', ''], uri, 'transfer', amounts[i], bytes)
      }
      let primaryUserAccount = await instanceUserManagement.getUserAccount(primaryUserId)
      let heldIds = await instanceTokenManagement.getHeldTokenIds(
        primaryUserAccount
      )
      console.log(primaryUserAccount)
      console.log(heldIds)
      assert.isAbove(heldIds.length, 0, 'No held token ids returned.')
      console.log(ids)
      console.log(amounts)
      for(i=0; i < heldIds.length; i++){
        switch(i){
          case 0: assert.equal(ids[i], heldIds[i], 'heldid corresponding to id0 does not match'); break;
          case 1: assert.equal(ids[i], heldIds[i], 'heldid corresponding to id1 does not match'); break;
          case 2: assert.equal(ids[i], heldIds[i], 'heldid corresponding to id2 does not match'); break;
          case 3: assert.equal(ids[i], heldIds[i], 'heldid corresponding to id3 does not match'); break;
          case 4: assert.equal(ids[i], heldIds[i], 'heldid corresponding to id4 does not match'); break;
          
        }
      }
      let balances = await instanceTokenManagement.getHeldTokenBalances(accounts[0])
      assert.isAbove(balances.length, 0, 'No held token ids returned.')

      for(i=0; i < balances.length; i++){
        switch(i){
          case 0: assert.equal(
              ethers.utils.parseUnits('1000000000',18).toString(), 
              balances[i].toString(), 
              'tokenId11555 does not match'
            )
          break;
          case 1: assert.equal(amounts[i-1], balances[i], 'batchmint balance1 does not match'); break;
          case 2: assert.equal(amounts[i-1], balances[i], 'batchmint balance2 does not match'); break;
          case 3: assert.equal(amounts[i-1], balances[i], 'batchmint balance3 does not match'); break;
          case 4: assert.equal(amounts[i-1], balances[i], 'batchmint balance4 does not match'); break;
          case 5: assert.equal(amounts[i-1], balances[i], 'batchmint balance5 does not match'); break;
          case 6: assert.equal(0, balances[i], 'erc721  balance does not match'); break;
          case 7: assert.equal(
              ethers.utils.parseUnits('900000000',18).toString(), 
              balances[i], 
              'minted fungible balance does not match'
            ) 
          break;
          case 8: assert.equal(0, balances[i], 'balanceB does not match'); break;
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

      let res = await instance.changeTransactionManager(secondTokenManagerAddr) 
      let transactionManagerAddr = await instance.getTransactionManager()
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
