const UserManagement = artifacts.require("UserManagement");

const TokenManagement = artifacts.require("TokenManagement");
let userAccount
let fakeTwitterId = 1230456987
let fakeTwitterHandle = '@fakeHandleC'
let fakeUrl = 'http://test.uri/101'

contract("UserManagement", async accounts => {
	it("create an account", async () => {
	    let instance = await UserManagement.deployed()
	    let tknMgmt = await TokenManagement.deployed()

	    instance.changeTokenManagerAddr(tknMgmt.address)

	    let res = await instance.launchL2Account(
	    	fakeTwitterId, 
	    	fakeTwitterHandle, 
	    	fakeUrl
	    )
	    
	    userAccount = res.logs[0]['args']['_address']
	    assert.notEqual('0x0000000000000000000000000000000000000000', userAccount, "Token Manager Address is zero address")
	    assert.lengthOf(
	      userAccount,
	      42,
	      "Token cryptoraves token Address not valid: "+userAccount
	    )
  	})
	it('check getUserAccount & getUserId functions', async () => {
		let instance = await UserManagement.deployed()
		let userId = await instance.getUserId(userAccount)
		let accountCheck = await instance.getUserAccount(userId)

		assert.equal(
			accountCheck,
			userAccount,
			'getUserId or getUserAccount failed'
		)
	})
	it("verify cryptoraves token address is valid", async () => {
		let instance = await UserManagement.deployed()
		let tokenManagerAddr = await instance.getTokenManagerAddr.call()

		assert.notEqual('0x0000000000000000000000000000000000000000', tokenManagerAddr, "Token Manager Address is zero address")
		assert.lengthOf(
		  tokenManagerAddr,
		  42,
		  "Token cryptoraves token Address not valid: "+tokenManagerAddr
		)
	})
	it('user account check w/ existing user', async () => {
		let instance = await UserManagement.deployed()
	    let res = await instance.getUser(fakeTwitterId)

	    assert.equal(res.account, userAccount, 'User account lookup doesn\'t match')
	    assert.equal(res.twitterHandle, fakeTwitterHandle, 'User platform handle lookup doesn\'t match')
	    assert.equal(res.imageUrl, fakeUrl, 'User image URL lookup doesn\'t match')
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
      isValidator = await instance.isAdministrator.call({from: accounts[2]})
      assert.isOk(!isValidator, "isAdmin failing. revert")
    }catch(e){
      //reverts as predicted
      assert.isOk(true)
    }
  });
  it("set a new administrator and check it", async () => {
    let instance = await UserManagement.deployed()
    let res = await instance.setAdministrator(accounts[1]) 
    let isValidator = await instance.isAdministrator.call({ from: accounts[1] })
    assert.isOk(
      isValidator,
      "isValidator failed with accounts[1] as msg.sender"
    );
  });
  it("should UNSET a new administrator and check it", async () => {
    let instance = await UserManagement.deployed()
    let res = await instance.setAdministrator(accounts[1]) 
    assert.isOk(res)
    res = await instance.unsetAdministrator(accounts[1]) 
    
    try{
      isValidator = await instance.isAdministrator.call({ from: accounts[1] })
      assert.isOk(!isValidator, "unsetValidator failing. Should revert")
    }catch(e){
      //reverts as predicted
      assert.isOk(true)
    }
  })
})