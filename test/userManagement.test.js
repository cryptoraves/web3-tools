const UserManagement = artifacts.require("UserManagement");

const TokenManagement = artifacts.require("TokenManagement");

contract("UserManagement", async accounts => {
	it("create an account", async () => {
    let instance = await UserManagement.deployed()
    let tknMgmt = await TokenManagement.deployed()

    instance.changeTokenManagerAddr(tknMgmt.address)

    let res = await instance.launchL2Account(
    	1230456987, 
    	'@fakeHandleC', 
    	'http://test.uri/101'
    )
    
    let userAccount = res.logs[0]['args']['_address']
    assert.notEqual('0x0000000000000000000000000000000000000000', userAccount, "Token Manager Address is zero address")
    assert.lengthOf(
      userAccount,
      42,
      "Token cryptoraves token Address not valid: "+userAccount
    )
  })

})