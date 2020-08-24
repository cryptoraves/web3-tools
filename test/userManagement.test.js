const UserManagement = artifacts.require("UserManagement");

const ethers = require('ethers')

const TransactionManagement = artifacts.require("TransactionManagement");
const TokenManagement = artifacts.require("TokenManagement")
let userAccount
let fakeTwitterId = 1230456987
let fakeTwitterHandle = '@fakeHandleC'
let fakeUrl = 'http://test.uri/101'

contract("UserManagement", async accounts => {
	it("create an account", async () => {
		let txnMgmt = await TransactionManagement.deployed()
	    let instance = await UserManagement.at(
	    	await txnMgmt.getUserManagementAddress()
	    )

	    let res = await instance.launchL2Account(
	    	fakeTwitterId, 
	    	fakeTwitterHandle, 
	    	fakeUrl
	    )
	    userAccount = await instance.getUserAccount(fakeTwitterId)
	    assert.notEqual('0x0000000000000000000000000000000000000000', userAccount, "Token Manager Address is zero address")
	    assert.lengthOf(
	      userAccount,
	      42,
	      "Token cryptoraves token Address not valid: "+userAccount
	    )
  	})
	it('check getUserAccount & getUserId functions', async () => {
		let txnMgmt = await TransactionManagement.deployed()
	    let instance = await UserManagement.at(
	    	await txnMgmt.getUserManagementAddress()
	    )
		let userId = await instance.getUserId(userAccount)
		let accountCheck = await instance.getUserAccount(userId)

		assert.equal(
			accountCheck,
			userAccount,
			'getUserId or getUserAccount failed'
		)
	})
	it('check getUserId from Handle', async () => {
		let txnMgmt = await TransactionManagement.deployed()
	    let instance = await UserManagement.at(
	    	await txnMgmt.getUserManagementAddress()
	    )
		let userId = await instance.getUserIdByPlatformHandle(fakeTwitterHandle)
		let account = await instance.getUser(userId)

		assert.equal(
			account.twitterHandle,
			fakeTwitterHandle,
			'getUserId from twitter handle failed'
		)
	})
	it("verify transaction manager address is valid", async () => {
		let txnMgmt = await TransactionManagement.deployed()
	    let instance = await UserManagement.at(
	    	await txnMgmt.getUserManagementAddress()
	    )
		let transactionManagerAddr = await instance.getTransactionManagerAddress.call()

		assert.notEqual('0x0000000000000000000000000000000000000000', transactionManagerAddr, "Token Manager Address is zero address")
		assert.lengthOf(
		  transactionManagerAddr,
		  42,
		  "Token cryptoraves token Address not valid: "+transactionManagerAddr
		)
	})
	it('user account check w/ existing user', async () => {
		let txnMgmt = await TransactionManagement.deployed()
	    let instance = await UserManagement.at(
	    	await txnMgmt.getUserManagementAddress()
	    )
	    let res = await instance.getUser(fakeTwitterId)

	    assert.equal(res.account, userAccount, 'User account lookup doesn\'t match')
	    assert.equal(res.twitterHandle, fakeTwitterHandle, 'User platform handle lookup doesn\'t match')
	    assert.equal(res.imageUrl, fakeUrl, 'User image URL lookup doesn\'t match')
	})
	it("changes an existing user's drop state and drops a new crypto", async () => {
		let TransactionManagementInstance = await TransactionManagement.deployed()
	    let instance = await UserManagement.at(
	    	await TransactionManagementInstance.getUserManagementAddress()
	    )
	    let fakeUserId = 328928374
	    let fakeUserId2 = 434443434
		//1. drop a new crypto
		let res = await TransactionManagementInstance.initCommand(
	      	[fakeUserId,0,0],
	      	['dropStateTester', '', ''],
	      	'https://i.picsum.photos/id/428928374/200/200.jpg',
	      	'launch',
	      	0,
	      	''
	    )
	    //2. transfer some
	    let res = await instance.initCommand(
			[fakeUserId,fakeUserId2,0],
			['dropStateTester', 'rando1', ''],
			'https://i.picsum.photos/id/428928374/200/200.jpg',
			'transfer',
			200000000,
			''
		)

		//3. reset dropState
		await instance.setDropState(fakeUserId, false)

		//4. Drop again
		let res = await TransactionManagementInstance.initCommand(
	      	[fakeUserId,0,0],
	      	['dropStateTesterReborn', '', ''],
	      	'https://i.picsum.photos/id/428928374222/200/200.jpg',
	      	'launch',
	      	0,
	      	''
	    )
		//5. transfer some again
	    let res = await instance.initCommand(
			[fakeUserId,fakeUserId2,0],
			['dropStateTesterReborn', 'rando1', ''],
			'https://i.picsum.photos/id/428928374222/200/200.jpg',
			'transfer',
			222222222,
			''
		)

	    //6. check new balance.
	    let instanceTokenManagement = await TokenManagement.at(
        	await TransactionManagementInstance.getTokenManagementAddress()
    	)
	    let wait CryptoravesToken.at(
	    	await instanceTokenManagement.getCryptoravesTokenAddress()
	    )

	    let user = await instance.getUser(fakeUserId)
	    let tokenId1155 = await instanceTokenManagement.getManagedTokenIdByAddress(
	    	user.account
	    )

	    user = await instance.getUser(fakeUserId2)
    	let balance = await instanceCryptoravesToken.balanceOf(user.account, tokenId1155)
	    assert.equal(
	    	balance,
	    	222222222,
	    	'Reset crypto drop failed. Resulting balance does not match'
	    )

	})







  //keep at bottom
  it("verify sender is admin", async () => {
    let instance = await UserManagement.deployed()
    let isValidator = await instance.isAdministrator.call()
    assert.isOk(
      isValidator,
      "isValidator failed with main address as msg.sender"
    );
  });
  it("revert since different sender is not admin", async () => {
    let instance = await UserManagement.deployed()
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
    let instance = await UserManagement.deployed()

    let wallet = ethers.Wallet.createRandom()

    let res = await instance.setAdministrator(wallet.address) 
    let isValidator = await instance.isAdministrator.call({ from: wallet.address })
    assert.isOk(
      isValidator,
      "isValidator failed with random wallet.address as msg.sender"
    );
  });
  it("should UNSET a new administrator and check it", async () => {
    let instance = await UserManagement.deployed()

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
  })
})