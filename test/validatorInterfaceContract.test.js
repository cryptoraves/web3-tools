const ValidatorInterfaceContract = artifacts.require("ValidatorInterfaceContract")

const TransactionManagement = artifacts.require("TransactionManagement");
const TokenManagement = artifacts.require("TokenManagement");
const UserManagement = artifacts.require("UserManagement");

const CryptoravesToken = artifacts.require("CryptoravesToken");
const ERC20Full = artifacts.require('ERC20Full')

const ethers = require('ethers')

const Web3 = require('web3');
const web3 = new Web3();

let secondTokenManagerAddr = ''
let ids = []
let amounts = []
let primaryUserId = 38845343252

//placeholder global obj
let txnMgmt2
let usrMgmt2
let tknMgmt2


contract("ValidatorInterfaceContract", async accounts => {
  
  //for iterateing through second token contract assignment
  for (var i = 0; i < 2; i++) {  
    it("Test Admin Configuration", async () => {
      let instance = await ValidatorInterfaceContract.deployed()
      let res = await instance.testDownstreamAdminConfiguration()
      assert.isOk(res);
    });
    it("Drop crypto", async () => {
      let instance = await ValidatorInterfaceContract.deployed()
      var bytes = ethers.utils.formatBytes32String('')
      let res = await instance.validateCommand(
      	[primaryUserId,0,0],
      	['@fakeHandle', '', ''],
        [0,0],
      	['twitter','launch','https://i.picsum.photos/id/1/200/200.jpg', bytes]
      )
      assert.isOk(res);
    });
    it("Transfer dropped crypto", async () => {
      let instance = await ValidatorInterfaceContract.deployed()
  	  var bytes = ethers.utils.formatBytes32String('')
      let res = await instance.validateCommand(
      	[primaryUserId,434443434,0],
      	['@fakeHandle', '@rando1', ''],
        [20074,2], //this represents a user-input value of 200.74 
      	['twitter','transfer','https://i.picsum.photos/id/1/200/200.jpg', bytes]
      )
      assert.isOk(res.receipt['status']);
    });
    it("Transfer 3rd party crypto", async () => {
      let instance = await ValidatorInterfaceContract.deployed()
      var bytes = ethers.utils.formatBytes32String('')
      let res = await instance.validateCommand(
      	[434443434,55667788,0],
      	['@rando1', '@rando2', ''],
        [50,0],
      	['twitter','transfer','https://i.picsum.photos/id/2/200/200.jpg', bytes]
      )
      assert.isOk(res.receipt['status']);
      res = await instance.validateCommand(
      	[434443434,primaryUserId,0],
      	['@rando1', '@rando2', ''],
        [50,0],
      	['twitter','transfer','https://i.picsum.photos/id/2/200/200.jpg', bytes]
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
    it("run heresMyAddress", async () => {
      let instance = await ValidatorInterfaceContract.deployed()
      let txnManagerAddr = await instance.getTransactionManagementAddress()
      
      var bytes = ethers.utils.formatBytes32String('')

      let additionalAccount = accounts[7]
      
      let res = await instance.validateCommand(
        [primaryUserId,0,0],
        ['@fakeHandle', '', ''],
        [0,0],
        ['twitter','mapaccount','https://i.picsum.photos/id/2/200/200.jpg', additionalAccount]
      )

      let instanceTransactionManagement = await TransactionManagement.at(
        await instance.getTransactionManagementAddress()
      )
      let instanceUserManagement = await UserManagement.at(
        await instanceTransactionManagement.getUserManagementAddress()
      )

      let l2Address = await instanceUserManagement.getLayerTwoAccount(additionalAccount)
      let user = await instanceUserManagement.getUserAccount(primaryUserId)
      assert.equal(l2Address, user, 'L1 address mapped to non-matching l2 address');
    });
    it("inits and sends erc20", async () => {
      let additionalAccount = accounts[7]
      let instance = await ValidatorInterfaceContract.deployed()
      let instanceTransactionManagement = await TransactionManagement.at(
        await instance.getTransactionManagementAddress()
      )
      // Launch an ERC20 and deposit some to instantiate onto Cryptoraves. Then send some to Twitter user L1
      let instanceTokenManagement = await TokenManagement.at(
        await instanceTransactionManagement.getTokenManagementAddress()
      )

      let erc20Instance = await ERC20Full.deployed()  
      let appr = await erc20Instance.approve(
        instanceTokenManagement.address,
        ethers.utils.parseUnits('1',18)
      )
      await instanceTokenManagement.deposit(
        ethers.utils.parseUnits('1',18), 
        erc20Instance.address,
        20, //indicates ERC20
        false
      )
      let tokenId1155 = await instanceTokenManagement.getManagedTokenIdByAddress(erc20Instance.address)
      let amt = ethers.utils.parseUnits('111',18)
      appr = await erc20Instance.approve(
        additionalAccount,
        amt
      )
      appr = await erc20Instance.transfer(
        additionalAccount,
        amt
      )
      res = await erc20Instance.balanceOf(additionalAccount)

      assert.ok(res >= amt, 'ERC20 deposit and send went awry')
    });
    it("Sign and send ERC20 deposit to proxy", async () => {
      let additionalAccount = accounts[7]
      let instance = await ValidatorInterfaceContract.deployed()
      let instanceTransactionManagement = await TransactionManagement.at(
        await instance.getTransactionManagementAddress()
      )
      let instanceTokenManagement = await TokenManagement.at(
        await instanceTransactionManagement.getTokenManagementAddress()
      )
      
      //create and sign transaction
      instanceTokenManagement.deposit()


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
        let rInt = getRandomInt(1, 99999999).toString()+'.0'

        amounts[i] = ethers.utils.parseUnits(rInt,18)
        let uri = 'https://i.picsum.photos/id/'+ids[i].toString()+'/200/200.jpg'
        await instance.validateCommand([ids[i],0,0], ['@rando'+ids[i].toString(), '', ''], [0,0], ['twitter','launch',uri, bytes])
        await instance.validateCommand([ids[i],primaryUserId,0], ['@rando'+ids[i].toString(), '@fakeHandle', ''], [amounts[i],18], ['twitter','transfer',uri, bytes])
      }
      let primaryUserAccount = await instanceUserManagement.getUserAccount(primaryUserId)
      let instanceCryptoravesToken = await CryptoravesToken.at(
        await instanceTokenManagement.getCryptoravesTokenAddress()
      )
      let heldIds = await instanceCryptoravesToken.getHeldTokenIds(
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
      let balances = await instanceCryptoravesToken.getHeldTokenBalances(primaryUserAccount)
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
        tknMgmt2 = await TokenManagement.new('http://fake.uri2.com')
        usrMgmt2 = await UserManagement.new()

        txnMgmt2 = await TransactionManagement.new(tknMgmt2.address, usrMgmt2.address)
        await txnMgmt2.setAdministrator(instance.address)

        await usrMgmt2.setAdministrator(txnMgmt2.address)
        await tknMgmt2.setAdministrator(txnMgmt2.address)
        
        secondTokenManagerAddr = txnMgmt2.address
      }else{
        secondTokenManagerAddr = ethers.Wallet.createRandom().address
      }

      let res = await instance.setTransactionManagementAddress(secondTokenManagerAddr) 
      let transactionManagerAddr = await instance.getTransactionManagementAddress()
      assert.equal(
        transactionManagerAddr,
        secondTokenManagerAddr,
        "setTransactionManagementAddress failed with random wallet.address as input"
      );
    });
  }
    it("verify sender is admin", async () => {
      let instance = await ValidatorInterfaceContract.deployed()
      let isValidator = await instance.isAdministrator(accounts[0])
      assert.isOk(
        isValidator,
        "isValidator failed with main address as msg.sender"
      );
    });
    it("revert since different sender is not admin", async () => {
      let instance = await ValidatorInterfaceContract.deployed()
      let isValidator
      try{
      	isValidator = await instance.isAdministrator(ethers.Wallet.createRandom().address)
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
      let isValidator = await instance.isAdministrator(wallet.address)
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
      	isValidator = await instance.isAdministrator(wallet.address)
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
