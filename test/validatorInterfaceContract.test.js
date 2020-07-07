const ValidatorInterfaceContract = artifacts.require("ValidatorInterfaceContract");
console.log(ValidatorInterfaceContract)
contract("ValidatorInterfaceContract", async accounts => {
  it("should deploy ValidatorSystem", async () => {
    let instance = await ValidatorInterfaceContract.deployed();
    let isValidator = await instance.getTokenManager.call()
    console.log(isValidator)
  });
});