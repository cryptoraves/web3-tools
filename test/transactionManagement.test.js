const TransactionManagement = artifacts.require("TransactionManagement")
const WalletFull = artifacts.require("WalletFull")
const ethers = require('ethers')

const UserManagement = artifacts.require("UserManagement")
let secondUserManagerAddr = ''
const CryptoravesToken = artifacts.require("CryptoravesToken")
let secondCryptoravesTokenAddr = ''

contract("TransactionManagement", async accounts => {
      
  //for iterateing through second token contract assignment
  for (var i = 0; i < 2; i++) {  

    it("Drop crypto with initCommand", async () => {
      let instance = await TransactionManagement.deployed()

      //var bytes = ethers.utils.formatBytes32String('testing crypto drop')
      let res = await instance.initCommand(
      	[1029384756,0,0],
      	['@fakeHandleA', '', ''],
      	'https://i.picsum.photos/id/111/200/200.jpg',
      	'launch',
      	0,
      	'testing crypto drop'
      )
      //for next test
      res = await instance.initCommand(
      	[1029388888,0,0],
      	['@fakeHandleB', '', ''],
      	'https://i.picsum.photos/id/111/201/200.jpg',
      	'launch',
      	0,
      	'testing crypto drop'
      )
      assert.isOk(res.receipt['status'])
    })
    it("Transfer dropped crypto via initCommand", async () => {
      let instance = await TransactionManagement.deployed()
      let res = await instance.initCommand(
        [1029384756,434443434,0],
        ['@fakeHandle', '@rando1', ''],
        'https://i.picsum.photos/id/1/200/200.jpg',
        'transfer',
        200,
        ''
      )
      assert.isOk(res.receipt['status']);
    });
    it("Transfer 3rd party crypto via initCommand", async () => {
      let instance = await TransactionManagement.deployed()
      let res = await instance.initCommand(
        [434443434,55667788,0],
        ['@rando1', '@rando2', ''],
        'https://i.picsum.photos/id/2/200/200.jpg',
        'transfer',
        50,
        ''
      )
      assert.isOk(res.receipt['status']);
      res = await instance.initCommand(
        [434443434,1029384756,0],
        ['@rando1', '@rando2', ''],
        'https://i.picsum.photos/id/2/200/200.jpg',
        'transfer',
        50,
        ''
      )
      assert.isOk(res.receipt['status']);
    });
    it("get token from twitter id", async () => {
      let instance = await TransactionManagement.deployed()
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
    it("twitter id not registered. Should revert.", async () => {
      let instance = await TransactionManagement.deployed()
      let tokenId
      try{
        tokenId = await instance.getTokenIdFromPlatformId.call(18)
        assert.isOk(!tokenId, "Test failed. Should revert due to non-existant platform ID")
      }catch(e){
        //reverts as predicted
        assert.isOk(true)
      }
    })
    it("verify cryptoraves token address is valid", async () => {
      let instance = await TransactionManagement.deployed()
      let tokenContractAddr = await instance.getCryptoravesTokenAddress.call()
      
      assert.notEqual('0x0000000000000000000000000000000000000000', tokenContractAddr, "Token Manager Address is zero address")
      assert.lengthOf(
        tokenContractAddr,
        42,
        "Token cryptoraves token Address not valid: "+tokenContractAddr
      )
    })

    it("set a new cryptoraves token address and check it", async () => {
      let instance = await TransactionManagement.deployed()

      if(secondCryptoravesTokenAddr==''){
        //assign new usermanagement and cryptoravestoken and re-run above tests
        let cTkn = await CryptoravesToken.deployed()
        await cTkn.setAdministrator(instance.address)
        secondCryptoravesTokenAddr = cTkn.address
      }else{
        secondCryptoravesTokenAddr = ethers.Wallet.createRandom().address
      }

      let res = await instance.changeCryptoravesTokenAddress(secondCryptoravesTokenAddr) 
      let cryptoravesTokenAddress = await instance.getCryptoravesTokenAddress.call()
      assert.equal(
        cryptoravesTokenAddress,
        secondCryptoravesTokenAddr,
        "changeCryptoravesTokenAddress failed with secondCryptoravesTokenAddr as input"
      )
    })
    it("verify userManagement contract address is valid", async () => {
      let instance = await TransactionManagement.deployed()
      let tokenContractAddr = await instance.getUserManagementAddress.call()
      
      assert.notEqual('0x0000000000000000000000000000000000000000', tokenContractAddr, "User Manager Address is zero address")
      assert.lengthOf(
        tokenContractAddr,
        42,
        "User management contract Address not valid: "+tokenContractAddr
      )
    })
    it("set a new userManagement address and check it", async () => {
      let instance = await TransactionManagement.deployed()

      if(secondUserManagerAddr == ''){
        //assign new usermanagement and re-run above tests
        let usrMgmt = await UserManagement.deployed()
        await usrMgmt.setAdministrator(instance.address)
        await usrMgmt.changeTokenManagerAddr(instance.address)
        secondUserManagerAddr = usrMgmt.address
      }else{
        secondUserManagerAddr = ethers.Wallet.createRandom().address
      }

      let res = await instance.changeUserManagementAddress(secondUserManagerAddr) 
      let userMgmtTokenAddress = await instance.getUserManagementAddress.call()
      assert.equal(
        userMgmtTokenAddress,
        secondUserManagerAddr,
        "changeUserManagementAddress failed with secondUserManagerAddr as input"
      )
    })
  }
  it("test heresmyaddress functions", async () => {
      let userManagementInstance = await UserManagement.deployed()
      let TransactionManagementInstance = await TransactionManagement.deployed()
      let cTkn = await CryptoravesToken.deployed()
      //change token management contract back to original
      await TransactionManagementInstance.changeUserManagementAddress(userManagementInstance.address)
      await TransactionManagementInstance.changeCryptoravesTokenAddress(cTkn.address)
      let res = await userManagementInstance.getUser(1029384756);
      let addr = res['account']
      res = await userManagementInstance.userHasL1AddressMapped(addr)
      assert.isFalse(
        res,
        "Issue checking L1 Mapped address. Should not exist."
      );
      res = await TransactionManagementInstance.initCommand(
        [1029384756,0,0],
        ['@rando2', '', ''],
        'https://i.picsum.photos/id/111/200/200.jpg',
        'mapaccount',
        0,
        secondCryptoravesTokenAddr
      )
      res = await userManagementInstance.userHasL1AddressMapped(addr)
      assert.isOk(
        res,
        "Issue checking L1 Mapped address. Random address should now be assigned but isn't."
      );
      res = await userManagementInstance.getL1AddressMapped(addr)
      assert.equal(
        res,
        secondCryptoravesTokenAddr,
        "L1 mapped address doesn't match given."
      );
    })
  it("ravepool activation & distribution", async () => {
    let userManagementInstance = await UserManagement.deployed()
    let TransactionManagementInstance = await TransactionManagement.deployed()

    let res = await TransactionManagementInstance.initCommand(
      [9929387656,0,0],
      ['@rando3', '', ''],
      'https://i.picsum.photos/id/333/200/200.jpg',
      'mapaccount',
      0,
      accounts[0]
    )
    res = await TransactionManagementInstance.initCommand(
        [9929387656,0,0],
        ['@rando3', '', ''],
        'https://i.picsum.photos/id/333/200/200.jpg',
        'launch',
        0,
        'crypto drop'
      )
    //get WalletFull (Ravepool) contract
    res = await userManagementInstance.getUser(9929387656);
    let walletFullAddr = res['account']
    res = await userManagementInstance.userHasL1AddressMapped(walletFullAddr)
    assert.isOk(res, "could not map address for new user")

    walletFullInstance = await WalletFull.at(walletFullAddr)
    res = await walletFullInstance.isRavepoolActivated()
    assert.isFalse(res, 'Ravepool should not be activated at this point')
    try{
      res = await walletFullInstance.activateRavepool({from: ethers.Wallet.createRandom().address})
      assert.isOk(false, "Activate Ravepool should fail here trying to activate from unauthorized address")
    }catch(e){
      assert.isOk(true)
    }
    await walletFullInstance.activateRavepool()
    res = await walletFullInstance.isRavepoolActivated()
    assert.isOk(res, 'Error activating Ravepool with authorized address')

    //await walletFullInstance.redeemAndBurnViaRavepool(_sentTokenId, _amountOfPersonalToken, _data)
  })


  it("verify sender is admin", async () => {
    let instance = await TransactionManagement.deployed()
    let isValidator = await instance.isAdministrator.call()
    assert.isOk(
      isValidator,
      "isValidator failed with main address as msg.sender"
    );
  });
  it("revert since different sender is not admin", async () => {
    let instance = await TransactionManagement.deployed()
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
    let instance = await TransactionManagement.deployed()

    let wallet = ethers.Wallet.createRandom()

    let res = await instance.setAdministrator(wallet.address) 
    let isValidator = await instance.isAdministrator.call({ from: wallet.address })
    assert.isOk(
      isValidator,
      "isValidator failed with random wallet.address as msg.sender"
    );
  });
  it("should UNSET a new administrator and check it", async () => {
    let instance = await TransactionManagement.deployed()
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
})  