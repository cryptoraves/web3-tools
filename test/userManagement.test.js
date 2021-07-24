const UserManagement = artifacts.require("UserManagement");

const ethers = require('ethers')

const TransactionManagement = artifacts.require("TransactionManagement");
const TokenManagement = artifacts.require("TokenManagement")
const CryptoravesToken = artifacts.require("CryptoravesToken")
let userAccount
let fakeTwitterId = 1230456987
let fakeTwitterHandle = 'fakeHandleC'
let fakeUrl = 'http://test.uri/101'

contract("UserManagement", async accounts => {
	it("create an account", async () => {
		let txnMgmt = await TransactionManagement.deployed()
	    let instance = await UserManagement.at(
	    	await txnMgmt.userManagementContractAddress()
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
	    	await txnMgmt.userManagementContractAddress()
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
	    	await txnMgmt.userManagementContractAddress()
	    )
		let userId = await instance.getUserIdByPlatformHandle(fakeTwitterHandle)
		let account = await instance.getUserStruct(userId)

		assert.equal(
			account.twitterHandle,
			fakeTwitterHandle,
			'getUserId from twitter handle failed'
		)
	})
	it("verify transaction manager address is valid", async () => {
		let txnMgmt = await TransactionManagement.deployed()
	    let instance = await UserManagement.at(
	    	await txnMgmt.userManagementContractAddress()
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
	    	await txnMgmt.userManagementContractAddress()
	    )
	    let res = await instance.getUserStruct(fakeTwitterId)

	    assert.equal(res.cryptoravesAddress, userAccount, 'User account lookup doesn\'t match')
	    assert.equal(res.twitterHandle, fakeTwitterHandle, 'User platform handle lookup doesn\'t match')
	    assert.equal(res.imageUrl, fakeUrl, 'User image URL lookup doesn\'t match')
	})

  //keep at bottom
  it("verify sender is admin", async () => {
  	let txnMgmt = await TransactionManagement.deployed()
    let instance = await UserManagement.at(
	    await txnMgmt.userManagementContractAddress()
	)
    let isValidator = await instance.isAdministrator(accounts[0])
    assert.isOk(
      isValidator,
      "isValidator failed with main address as msg.sender"
    );
  });
  it("revert since different sender is not admin", async () => {
  	let txnMgmt = await TransactionManagement.deployed()
    let instance = await UserManagement.at(
	    await txnMgmt.userManagementContractAddress()
	)
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
  	let txnMgmt = await TransactionManagement.deployed()
    let instance = await UserManagement.at(
	    await txnMgmt.userManagementContractAddress()
	)

    let wallet = ethers.Wallet.createRandom()

    let res = await instance.setAdministrator(wallet.address)
    let isValidator = await instance.isAdministrator(wallet.address)
    assert.isOk(
      isValidator,
      "isValidator failed with random wallet.address as msg.sender"
    );
  });
  it("should UNSET a new administrator and check it", async () => {
  	let txnMgmt = await TransactionManagement.deployed()
    let instance = await UserManagement.at(
	    await txnMgmt.userManagementContractAddress()
	)

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
  })
})
