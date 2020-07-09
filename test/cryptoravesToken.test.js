const CryptoravesToken = artifacts.require("CryptoravesToken");

contract("CryptoravesToken", async accounts => {
  it("should Launch CryptoravesToken Contract", async () => {
    let instance = await CryptoravesToken.deployed()
    //let balance = await instance.getBalance.call(accounts[0]);
    //assert.equal(balance.valueOf(), 10000);
    console.log(instance)
  })
})  
