const ValidatorInterfaceContract = artifacts.require("ValidatorInterfaceContract");
console.log(ValidatorInterfaceContract)
contract("ValidatorInterfaceContract", async accounts => {
  it("should deploy ValidatorInterfaceContract", async () => {
  	console.log('here')
    let instance = await ValidatorInterfaceContract.deployed();
    console.log('here1')
    let isValidator = await instance.getTokenManager.call()
    console.log(isValidator)
  });
});