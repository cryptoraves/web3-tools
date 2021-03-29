const ValidatorInterfaceContract = artifacts.require("ValidatorInterfaceContract")

const TransactionManagement = artifacts.require("TransactionManagement");
const TokenManagement = artifacts.require("TokenManagement");
const UserManagement = artifacts.require("UserManagement");

const CryptoravesToken = artifacts.require("CryptoravesToken");
const ERC20Full = artifacts.require('ERC20Full')

const ethers = require('ethers')

const Web3 = require('web3')
const web3 = new Web3()
web3.setProvider(new web3.providers.HttpProvider())

let secondTokenManagerAddr = ''
let ids = []
let amounts = []
let primaryUserId = 38845343252

//placeholder global obj
let txnMgmt2
let usrMgmt2
let tknMgmt2
let signerAccount

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
      	[primaryUserId,0,0,0,0, 1234567890],
      	['@fakeHandle', '', '','twitter','launch','https://i.picsum.photos/id/1/200/200.jpg'],
      	[bytes],
        bytes
      )
      assert.isOk(res);
    });
    it("Transfer dropped crypto", async () => {
      let instance = await ValidatorInterfaceContract.deployed()
  	  var bytes = ethers.utils.formatBytes32String('')
      let res = await instance.validateCommand(
      	[primaryUserId,99434443434,0,20074,2, 1234567891], //20074,2 represents a user-input value of 200.74 
      	['@fakeHandle', '@rando1', '','twitter','transfer','https://i.picsum.photos/id/1/200/200.jpg'],
      	[bytes],
        bytes
      )
      assert.isOk(res.receipt['status']);
    });
    it("Transfer 3rd party crypto", async () => {
      let instance = await ValidatorInterfaceContract.deployed()
      var bytes = ethers.utils.formatBytes32String('')
      let res = await instance.validateCommand(
      	[99434443434,55667788,0,50,0, 1234567892],
      	['@rando1', '@rando2', '','twitter','transfer','https://i.picsum.photos/id/2/200/200.jpg'],
      	[bytes],
        bytes
      )
      assert.isOk(res.receipt['status']);
      res = await instance.validateCommand(
      	[99434443434,primaryUserId,0,50,0, 1234567893],
      	['@rando1', '@rando2', '','twitter','transfer','https://i.picsum.photos/id/2/200/200.jpg'],
      	[bytes],
        bytes
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

      signerAccount = ethers.Wallet.createRandom()
      let additionalAccount = signerAccount.address //random addr
      
      let res = await instance.validateCommand(
        [primaryUserId,0,0,0,0, 1234567894],
        ['@fakeHandle', '', '', 'twitter','mapaccount','https://i.picsum.photos/id/2/200/200.jpg',additionalAccount],
        [],
        bytes
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
      let additionalAccount = signerAccount.address 
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
    /*it("Sign and send ERC20 deposit to proxy", async () => {

      let instance = await ValidatorInterfaceContract.deployed()
      let instanceTransactionManagement = await TransactionManagement.at(
        await instance.getTransactionManagementAddress()
      )
      let instanceTokenManagement = await TokenManagement.at(
        await instanceTransactionManagement.getTokenManagementAddress()
      )
      let erc20Instance = await ERC20Full.deployed()  
      let res1 = await erc20Instance.balanceOf(signerAccount.address)
      console.log("Starting ERC20 Balance: ", res1.toString())

      //send approval transaction from signer via erc20/721
      let fnSignature = web3.utils.keccak256("approve(address,uint256)").substr(0,10)
      let amount = ethers.utils.parseUnits('11',18)
      let fnParams = web3.eth.abi.encodeParameters(
        ["address","uint256"],
        [
          signerAccount.address,
          amount
        ]
      )
      let calldata = fnSignature + fnParams.substr(2)
      console.log('Calldata: ',calldata)
      let rawData = web3.eth.abi.encodeParameters(
        ['address','bytes'],
        [erc20Instance.address,calldata]
      );
      let hash = web3.utils.soliditySha3(rawData)
      let signature = await web3.eth.accounts.sign(hash, signerAccount.signingKey.privateKey)
      let accounts2 = ethers.Wallet.createRandom().address
      assert.ok(signature.signature.startsWith('0x'), 'Offline Signature failed')
      console.log('Signature: ',signature.signature)
      console.log('ERC20 Contract Address:', erc20Instance.address)
      console.log('Signer/Sender Address', signerAccount.address)
      console.log('Destination Address', accounts2)
      

      let res = await instance.validateCommand(
        [0,0,0,0,0], 
        ['', '', '', 'twitter','proxy',''], 
        [signature.signature, erc20Instance.address],
        calldata
      )
      console.log('Tx: ',res.tx)

      //send erc20 to a rando
      fnSignature = web3.utils.keccak256("transfer(address,uint256)").substr(0,10)
      fnParams = web3.eth.abi.encodeParameters(
        ["address","uint256"],
        [
          accounts2,
          amount
        ]
      )
      calldata = fnSignature + fnParams.substr(2)
      console.log('Calldata: ',calldata)
      rawData = web3.eth.abi.encodeParameters(
        ['address','bytes'],
        [erc20Instance.address,calldata]
      )
      hash = web3.utils.soliditySha3(rawData)
      signature = await web3.eth.accounts.sign(hash, signerAccount.signingKey.privateKey)
      console.log('Signature: ',signature.signature)
      assert.ok(signature.signature.startsWith('0x'), 'Offline Signature failed')
      console.log('Sent Amount: ', amount.toString())
      res = await instance.validateCommand(
        [0,0,0,0,0], 
        ['', '', '', 'twitter','proxy',''], 
        [signature.signature, erc20Instance.address],
        calldata
      )
      console.log('Tx2: ', res.tx)
      let res2 = await erc20Instance.balanceOf(signerAccount)
      console.log("Starting ERC20 Balance: ", res2.toString())


      //create and sign transaction for instanceTokenManagement.deposit()
      fnSignature = web3.utils.keccak256("deposit(uint256,address,uint,bool)").substr(0,10)

      fnParams = web3.eth.abi.encodeParameters(
        ["uint256","address","uint","bool"],
        [
          amount, //_amountOrId
          erc20Instance.address, //_contract
          20, //_ercType
          true //_managedTransfer. True because we want the deposit to go straight to the Cryptoraves managed wallet
        ]
      )
      calldata = fnSignature + fnParams.substr(2)
      console.log('Calldata: ',calldata)
      rawData = web3.eth.abi.encodeParameters(
        ['address','bytes'],
        [instanceTokenManagement.address,calldata]
      );
      // hash the data.
      hash = web3.utils.soliditySha3(rawData);
      // sign the hash.
      signature = await web3.eth.sign(hash, signerAccount)
      console.log('Signature: ',signature)
      assert.ok(signature.startsWith('0x'), 'Offline Signature failed')

      console.log(signerAccount)
      //now send the signed transaction ad cryptoraves Admin
      res = await instance.validateCommand(
        [0,0,0,0,0], 
        ['', '', '', 'twitter','proxy',''], 
        [signature, instanceTokenManagement.address],
        calldata
      )

      console.log(res)
      /*console.log(erc20Instance.address)
      console.log(signerAccount)
      console.log(accounts[0])
      console.log(res.receipt.logs)
      console.log(res.receipt.rawLogs)
      
      assert.ok(
        res.receipt.from == accounts[0] &&
        res.tx.startsWith('0x')
        , 
        'Proxy tx execution failed'
      )
      

    });*/
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
        await instance.validateCommand([ids[i],0,0,0,0, 1234567895], ['@rando'+ids[i].toString(), '', '', 'twitter','launch',uri], [bytes], bytes)
        await instance.validateCommand([ids[i],primaryUserId,0, amounts[i],18, 1234567896], ['@rando'+ids[i].toString(), '@fakeHandle', '','twitter','transfer',uri], [bytes], bytes)
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
