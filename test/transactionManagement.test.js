const TransactionManagement = artifacts.require("TransactionManagement")
const WalletFull = artifacts.require("WalletFull")
const ethers = require('ethers')

const UserManagement = artifacts.require("UserManagement")
const CryptoravesToken = artifacts.require("CryptoravesToken")
let secondUserManagerAddr = ''
let secondTokenManagerAddr = ''
const TokenManagement = artifacts.require("TokenManagement")


contract("TransactionManagement", async accounts => {
      
  //for iterateing through second token contract assignment
  for (var i = 0; i < 2; i++) {  

    it("Drop crypto with initCommand", async () => {
      let instance = await TransactionManagement.deployed()

      //var bytes = ethers.utils.formatBytes32String('testing crypto drop')
      let res = await instance.initCommand(
      	[1029384756,0,0],
      	['fakeHandleA', '', ''],
        0,
      	['twitter','launch','https://i.picsum.photos/id/111/200/200.jpg','testing crypto drop'],
      )
      //for next test
      res = await instance.initCommand(
      	[1029388888,0,0],
      	['fakeHandleB', '', ''],
        0,
      	['twitter','launch','https://i.picsum.photos/id/112/200/200.jpg','testing crypto drop']
      )
      assert.isOk(res.receipt['status'])
    })
    it("Test username-as-ticker lookup", async () => {
      let TransactionManagementInstance = await TransactionManagement.deployed()
      let userManagementInstance = await UserManagement.at(
        await TransactionManagementInstance.getUserManagementAddress()
      )  
      let tokenManagementInstance = await TokenManagement.at(
        await TransactionManagementInstance.getTokenManagementAddress()
      )
      let userId = await userManagementInstance.getUserIdByPlatformHandle('fakeHandleA')
      let account = await userManagementInstance.getUserAccount(userId)
      let symbol = await tokenManagementInstance.getSymbol(
        await tokenManagementInstance.getManagedTokenIdByAddress(account)
      )
      assert.equal(
        symbol,
        'fakeHandleA',
        'User Symbol matching error'
      )
    })
    it("Transfer dropped crypto via initCommand", async () => {
      let instance = await TransactionManagement.deployed()
      let res = await instance.initCommand(
        [1029384756,434443434,0],
        ['fakeHandle', 'rando1', ''],
        200,
        ['twitter','transfer','https://i.picsum.photos/id/1/200/200.jpg',''],
      )
      assert.isOk(res.receipt['status'], 'Transfer to rando1 failed')
    });
    it("Transfer 3rd party crypto via initCommand", async () => {
      let instance = await TransactionManagement.deployed()
      let res = await instance.initCommand(
        [434443434,55667788,1029384756],
        ['rando1', 'rando2', 'fakeHandle'],
        50,
        ['twitter','transfer','https://i.picsum.photos/id/2/200/200.jpg','']
      )
      assert.isOk(res.receipt['status'], 'Transfer to rando2 failed')
      res = await instance.initCommand(
        [434443434,1029384756,1029384756],
        ['rando1', 'rando3', 'fakeHandle'],
        50,
        ['twitter','transfer','https://i.picsum.photos/id/2/200/200.jpg','']
      )
      assert.isOk(res.receipt['status'], 'Transfer to rando3 failed')
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
    it("test heresmyaddress functions", async () => {
      let TransactionManagementInstance = await TransactionManagement.deployed()
      let userManagementInstance = await UserManagement.at(
        await TransactionManagementInstance.getUserManagementAddress()
      )  
      let cTkn = await TokenManagement.at(
        await TransactionManagementInstance.getTokenManagementAddress()
      )
      //set token management contract back to original
      let res = await userManagementInstance.getUser(1029384756);
      let addr = res['account']
      let randoAddr = ethers.Wallet.createRandom().address
      res = await userManagementInstance.userHasL1AddressMapped(addr)
      assert.isFalse(
        res,
        "Issue checking L1 Mapped address. Should not exist."
      );
      res = await TransactionManagementInstance.initCommand(
        [1029384756,0,0],
        ['rando2', '', ''],
        0,
        ['twitter','mapaccount','https://i.picsum.photos/id/111/200/200.jpg',randoAddr]
      )
      res = await userManagementInstance.getUser(1029384756);
      res = await userManagementInstance.userHasL1AddressMapped(addr)
      assert.isOk(
        res,
        "Issue checking L1 Mapped address. Random address should now be assigned but isn't."
      );
      res = await userManagementInstance.getLayerOneAccount(addr)
      assert.equal(
        res,
        randoAddr,
        "L1 mapped address doesn't match given."
      );
    })
    it("sets an existing user's drop state and drops a new crypto", async () => {
      let TransactionManagementInstance = await TransactionManagement.deployed()
      let fakeUserId = 328928374
      let fakeUserId2 = 434443434
      //1. drop a new crypto
      let res = await TransactionManagementInstance.initCommand(
          [fakeUserId,0,0],
          ['dropStateTester', '', ''],
          0,
          ['twitter','launch','https://i.picsum.photos/id/898/200/200.jpg',''],
      )
      //2. transfer some
      res = await TransactionManagementInstance.initCommand(
        [fakeUserId,fakeUserId2,0],
        ['dropStateTester', 'rando1', ''],
        200000000,
        ['twitter','transfer','https://i.picsum.photos/id/899/200/200.jpg','']
      )

      //get original tokenID
      let instanceTokenManagement = await TokenManagement.at(
          await TransactionManagementInstance.getTokenManagementAddress()
      )
      let userManagementInstance = await UserManagement.at(
        await TransactionManagementInstance.getUserManagementAddress()
      ) 
      let user = await userManagementInstance.getUser(fakeUserId)
      let tokenId1155_A = await instanceTokenManagement.getManagedTokenIdByAddress(
        user.account
      )

      //3. reset tokenDropState
      await TransactionManagementInstance.resetTokenDrop(fakeUserId)

      //4. Drop again
      res = await TransactionManagementInstance.initCommand(
          [fakeUserId,0,0],
          ['dropStateTesterReborn', '', ''],
          0,
          ['twitter','launch','https://i.picsum.photos/id/899/200/200.jpg','']
      )
      //5. transfer some again
      res = await TransactionManagementInstance.initCommand(
        [fakeUserId,fakeUserId2,0],
        ['dropStateTesterReborn', 'rando1', ''],
        222222222,
        ['twitter','transfer','https://i.picsum.photos/id/899/200/200.jpg','']
      )
      //6. check new balance.
      let instanceCryptoravesToken = await CryptoravesToken.at(
        await instanceTokenManagement.getCryptoravesTokenAddress()
      )
      
      let tokenId1155_B = await instanceTokenManagement.getManagedTokenIdByAddress(
        user.account
      )
      user = await userManagementInstance.getUser(fakeUserId2)
      let balance = await instanceCryptoravesToken.balanceOf(user.account, tokenId1155_B)
      assert.notEqual(
        tokenId1155_A,
        tokenId1155_B,
        'tokenId1155\'s should not match'
      )
      assert.equal(
        balance,
        222222222,
        'Reset crypto drop failed. Resulting balance does not match'
      )

      //7. change ticker and emoji
      await instanceTokenManagement.setSymbol(tokenId1155_B, 'NEWFAKESYMBOL')
      await instanceTokenManagement.setEmoji(tokenId1155_B, '💫')
      assert.isOk(
        await instanceTokenManagement.getSymbol(tokenId1155_B) == 'NEWFAKESYMBOL',
        await instanceTokenManagement.getEmoji(tokenId1155_B) == '💫',
        'get/set emoji and/or symbol failed'
      )

    })
    it("set a new userManagement & TokenManagement address and check it", async () => {
      let instance = await TransactionManagement.deployed()
      let usrMgmt = await UserManagement.deployed()
      let tknMgmt = await TokenManagement.deployed()

      if(secondUserManagerAddr == ''){
        //assign new usermanagement and re-run above tests
        await usrMgmt.setAdministrator(instance.address)
        secondUserManagerAddr = usrMgmt.address
        await tknMgmt.setAdministrator(instance.address)
        secondTokenManagerAddr = tknMgmt.address
      }else{
        await usrMgmt.unsetAdministrator(await usrMgmt.getTransactionManagerAddress())
        secondUserManagerAddr = ethers.Wallet.createRandom().address
        await tknMgmt.unsetAdministrator(await tknMgmt.getTransactionManagerAddress())
        secondTokenManagerAddr = ethers.Wallet.createRandom().address
      }
      await instance.setUserManagementAddress(secondUserManagerAddr) 
      await instance.setTokenManagementAddress(secondTokenManagerAddr) 
      let userMgmtTokenAddress = await instance.getUserManagementAddress.call()
      assert.equal(
        userMgmtTokenAddress,
        secondUserManagerAddr,
        "setUserManagementAddress failed with secondUserManagerAddr as input"
      )
    })
  }
  
  /*it("ravepool activation & distribution", async () => {
    let userManagementInstance = await UserManagement.deployed()
    let TransactionManagementInstance = await TransactionManagement.deployed()

    let res = await TransactionManagementInstance.initCommand(
      [9929387656,0,0],
      ['rando3', '', ''],
      'https://i.picsum.photos/id/333/200/200.jpg',
      'mapaccount',
      0,
      accounts[0]
    )
    res = await TransactionManagementInstance.initCommand(
        [9929387656,0,0],
        ['rando3', '', ''],
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
  })*/


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