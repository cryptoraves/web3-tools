const ValidatorInterfaceContract = artifacts.require("ValidatorInterfaceContract")
const CryptoravesToken = artifacts.require("CryptoravesToken");

let cryptoravesTokenAddr

//first launch parent contract
contract("ValidatorInterfaceContract", async accounts => {
  
  it("verify token manager address is valid", async () => {
    let instance = await ValidatorInterfaceContract.deployed()
    let tokenManagerAddr = await instance.getTokenManager.call()
    
    cryptoravesTokenAddr = tokenManagerAddr
    assert.notEqual('0x0000000000000000000000000000000000000000', tokenManagerAddr, "Token Manager Address is zero address")
    assert.lengthOf(
      tokenManagerAddr,
      42,
      "Token Manager Address not valid: "+tokenManagerAddr
    )
  })
})
contract("CryptoravesToken", async accounts => {
  it("should Launch CryptoravesToken Contract", async () => {
    let instance = await CryptoravesToken.deployed(cryptoravesTokenAddr)
    //let balance = await instance.getBalance.call(accounts[0]);
    //assert.equal(balance.valueOf(), 10000);
    console.log(instance)
    console.log(cryptoravesTokenAddr)
  })
})  
