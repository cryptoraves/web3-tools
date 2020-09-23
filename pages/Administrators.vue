<template>  
  <div 
    class="container"
  >
    <div v-if="ready">

      <div class="highlight">
        <h2
          v-if="networkType == 'SKALE Testnet'" 
          class="subtitle"
          style="background-color:#7CFC00"
        >
          Network: {{ this.networkType }} 
        </h2>
        <h2
          v-else-if="networkType == 'rinkeby'" 
          class="subtitle"
          style="background-color:#F0E68C"
        >
          Network: {{ this.networkType }} 
        </h2>
        <h2
          v-else-if="networkType == 'main'" 
          class="subtitle"
          style="background-color:#DC143C"
        >
          Network: {{ this.networkType }} 
        </h2>
        <h2
          v-else 
          class="subtitle"
          style="background-color:#80ccff"
        >
          Network: {{ this.networkType }} 
        </h2>
      </div>
      <br><br><br>
      <h1 class="title">
        Admin Functions
      </h1>
      <h2 class="subtitle">
        For Administering Contract Upgrades and End User Support
      </h2>
      <div class="links">
        <br>
        <a
          target="_blank" 
          @click="goEtherscan(ethereumAddress)">
          Your Wallet Address: {{ this.ethereumAddress }}
        </a>
        <div
          v-if="!UserManagementContractAddress && !showLoading" 
          class="links">
          <a
            @click="launchUserManagementContract()"
            class="button--green"
          >
            Launch User Manager Contract
          </a>
        </div>
        <div
          v-else
          class="links">
            <a
              target="_blank"
              @click="goEtherscan(UserManagementContractAddress)">
              User Management Contract Address: {{ this.UserManagementContractAddress }}
            </a>
        </div>
        <div
          v-if="UserManagementContractAddress && !TokenManagementContractAddress && !showLoading" 
          class="links">
          <a
            @click="launchTokenManagementContract(uri)"
            class="button--green"
          >
            Launch Token Manager Contract
          </a>
        </div>
        <div
          v-if="UserManagementContractAddress && TokenManagementContractAddress"
          class="links">
            <a
              target="_blank"
              @click="goEtherscan(TokenManagementContractAddress)">
              Token Management Contract Address: {{ this.TokenManagementContractAddress }}
            </a>
        </div>
        <div
            v-if="CryptoravesTokenContractAddress && !showLoading" 
            class="links">
          <a
              target="_blank"
              @click="goEtherscan(CryptoravesTokenContractAddress)">
              Cryptoraves Token Contract Address: {{ this.CryptoravesTokenContractAddress }}
            </a>
        </div>
        <div
          v-if="CryptoravesTokenContractAddress && !TransactionManagementContractAddress && !showLoading" 
          class="links">
          <a
            @click="launchTransactionManagementContract(TokenManagementContractAddress, UserManagementContractAddress)"
            class="button--green"
          >
            Launch Transaction Manager Contract
          </a>
        </div>
        <div
          v-if="CryptoravesTokenContractAddress && TransactionManagementContractAddress"
          class="links">
            <a
              target="_blank"
              @click="goEtherscan(TransactionManagementContractAddress)">
              Transaction Management Contract Address: {{ this.TransactionManagementContractAddress }}
            </a>
        </div>
        <div
          v-if="TransactionManagementContractAddress && !ValidatorContractAddress && !showLoading" 
          class="links">
          <a
            @click="launchValidatorContract()"
            class="button--green"
          >
            Launch Validator Contract
          </a>
        </div>
        <div
          v-if="TransactionManagementContractAddress && ValidatorContractAddress"
          class="links">
            <a
              target="_blank"
              @click="goEtherscan(ValidatorContractAddress)">
              Validator Contract Address: {{ this.ValidatorContractAddress }}
            </a>
        </div>
        <div
          class="links">
          <a
            v-if="ValidatorContractAddress"
            @click="testVariables()"
            class="button--green"
          >
            Test Admin Functions
          </a>
        </div> 
        <div
          class="links">
          <a
            v-if="ValidatorContractAddress && ! ERC20FullAddress"
            @click="launchERC20()"
            class="button--green"
          >
            Launch An ERC20
          </a>
        </div> 
        <div
          v-if="ERC20FullAddress"
          class="links">
          <a
              target="_blank"
              @click="goEtherscan(ERC20FullAddress)">
              Test ERC20 Contract Address: {{ this.ERC20FullAddress }}
          </a>
          <br>
          <a
            
            @click="depositERC20()"
            class="button--green"
          >
            Deposit Test ERC20 Tokens
          </a>
        </div> 
        <div
          v-if="showLoading"
        >
          <img 
            src="../assets/gif/loading.gif" 
            alt >
        </div>
        <div 
            v-if="UserManagementContractAddress"
            class="links">
            <br>
            <br>
            <a
              @click="resetLocalStorage()"
              class="button--green"
            >
              Start From Scratch
            </a>
          </div>
      </div>
    </div>
  </div>
</template>

<script>
import MetamaskHandler from "./metamaskHandler"
import abis from "./abis"
export default {
  name: "AdminTools",
  extends: MetamaskHandler,
  components: {},
  data() {
    return {
      contractNames: ["CryptoravesToken", "ERC20Full", "TokenManagement", "TransactionManagement", "UserManagement", "ValidatorInterfaceContract"],
      ethereumAddress: null,
      networkType: null,
      errorMsg: null,
      ready: null,
      uri: null,
      UserManagementContractAddress: null,
      UserManagementContractAddress: null,
      TokenManagementContractAddress: null,
      CryptoravesTokenContractAddress: null,
      TransactionManagementContractAddress: null,
      ValidatorContractAddress: null,
      ERC20FullAddress: null,
      ERC1155tokenId: 0,
      showLoading: false
    }
  },
  created() {
    this.checkAbis()
    this.ready = true
    this.uri = 'https://a.b.com'
  },
  mounted() {
    if (localStorage.CryptoravesTokenContractAddress) this.CryptoravesTokenContractAddress = localStorage.CryptoravesTokenContractAddress
    if (localStorage.UserManagementContractAddress) this.UserManagementContractAddress = localStorage.UserManagementContractAddress
    if (localStorage.TokenManagementContractAddress) this.TokenManagementContractAddress = localStorage.TokenManagementContractAddress
    if (localStorage.TransactionManagementContractAddress) this.TransactionManagementContractAddress = localStorage.TransactionManagementContractAddress
    if (localStorage.ValidatorContractAddress) this.ValidatorContractAddress = localStorage.ValidatorContractAddress 

    if (localStorage.ERC20FullAddress) this.ERC20FullAddress = localStorage.ERC20FullAddress
  },
  methods: {
    checkAbis(){
      this.contractNames.forEach(function(element) {
        if(typeof abis[element] === 'undefined') {
          throw new Error('No ABI found for '+element)    
        }
      })
      return true
    },

    async launchUserManagementContract(){
      let factory = new this.ethers.ContractFactory(abis["UserManagement"].abi, abis["UserManagement"].bytecode, this.signer);
      let contract = await factory.deploy();
      this.showLoading = true
      let tx = await contract.deployed()
      this.UserManagementContractAddress = localStorage.UserManagementContractAddress = contract.address
      this.showLoading = false
    },
    async launchTokenManagementContract(uri){
      let factory = new this.ethers.ContractFactory(abis["TokenManagement"].abi, abis["TokenManagement"].bytecode, this.signer);
      let contract = await factory.deploy(uri);
      this.showLoading = true
      let tx = await contract.deployed()
      
      this.TokenManagementContractAddress = localStorage.TokenManagementContractAddress = contract.address
      this.CryptoravesTokenContractAddress = localStorage.CryptoravesTokenContractAddress = await contract.getCryptoravesTokenAddress()

      //set admin for cryptoraves token (to allow minting rights)
      let cryptoravesTokenContract = new this.ethers.Contract(
        this.CryptoravesTokenContractAddress, 
        abis['CryptoravesToken'].abi, 
        this.signer
      )
      await cryptoravesTokenContract.setAdministrator(this.TokenManagementContractAddress)
      if(
        await cryptoravesTokenContract.isAdministrator(this.TokenManagementContractAddress)
      ){
        console.log("Set Admin For Token Manager")
      }
      this.showLoading = false
    },
    async launchTransactionManagementContract(_tokenManagementAddr, _userManagementAddr){

      let factory = new this.ethers.ContractFactory(abis["AdminToolsLibrary"].abi, abis["AdminToolsLibrary"].bytecode, this.signer);
      let contract = await factory.deploy()
      console.log('AdminToolsContract Address:', contract.address)
      //console.log(abis["TransactionManagement"].bytecode)
      let bytecode = this.linkLibrary(abis["TransactionManagement"].bytecode, 'AdminToolsLibrary', '0xa98D28dd4CE2da71f2A1Ea36160f06dA7582C9Ae')
      
      factory = new this.ethers.ContractFactory(abis["TransactionManagement"].abi, bytecode, this.signer);
      contract = await factory.deploy(_tokenManagementAddr, _userManagementAddr);
      this.showLoading = true
      let tx = await contract.deployed()
      
      this.TransactionManagementContractAddress = localStorage.TransactionManagementContractAddress = contract.address

      //set as admin for all downstream contracts
      contract = new this.ethers.Contract(
        this.TokenManagementContractAddress, 
        abis["TokenManagement"].abi, 
        this.signer
      )
      await contract.setAdministrator(this.TransactionManagementContractAddress)
      if(
        await contract.isAdministrator(this.TransactionManagementContractAddress)
      ){
        console.log("Set Admin For Token Manager")
      }
      
      contract = new this.ethers.Contract(
        this.UserManagementContractAddress, 
        abis["UserManagement"].abi, 
        this.signer
      )
      await contract.setAdministrator(this.TransactionManagementContractAddress)
      if(
        await contract.isAdministrator(this.TransactionManagementContractAddress)
      ){
        console.log("Set Admin For User Manager")
      }
      this.showLoading = false
    },
    async launchValidatorContract(){

      let factory = new this.ethers.ContractFactory(abis["ValidatorInterfaceContract"].abi, abis["ValidatorInterfaceContract"].bytecode, this.signer);

      //URI goes in here in place of ''
      let contract = await factory.deploy(
        this.TransactionManagementContractAddress
      );
      this.showLoading = true
      let tx = await contract.deployed()
      
    
      this.ValidatorContractAddress = localStorage.ValidatorContractAddress = contract.address

      //set as admin of transaction Manager
      let transactionManagement = new this.ethers.Contract(
        this.TransactionManagementContractAddress, 
        abis["TransactionManagement"].abi, 
        this.signer
      )
      try{
        await transactionManagement.setAdministrator(this.ValidatorContractAddress)
        if(
          await contract.isAdministrator(this.ValidatorContractAddress)
        ){
          console.log('Set Admin For Transaction Manager')
        }
      } catch(e) {
        throw new Error(e)
      }
      this.showLoading = false
    },
    async testVariables(){

      let contract = new this.ethers.Contract(
        this.ValidatorContractAddress, 
        abis['ValidatorInterfaceContract'].abi, 
        this.signer
      )


      //console.log('New Validator Address',await contract.setValidator('0xa0c0Cf61cED375Fcb25Cec028919bD45a96Ffb64'))
      console.log('Am I ValidatorInterfaceContract Administrator:', await contract.isAdministrator(this.ethereumAddress))
      let txnManagerAddress = await contract.getTransactionManagementAddress()
      console.log('TransactionManager Address Matches:', txnManagerAddress==this.TransactionManagementContractAddress)

      let transactionManagerContract = new this.ethers.Contract(
        txnManagerAddress, 
        abis['TransactionManagement'].abi, 
        this.signer
      )
      console.log('Am I TransactionManagement Administrator: ', await transactionManagerContract.isAdministrator(this.ethereumAddress))
      console.log('Is ValidatorInterfaceContract an Administrator: ', await transactionManagerContract.isAdministrator(this.ValidatorContractAddress))

      let tokenMgmtContractAddress = await transactionManagerContract.getTokenManagementAddress()
      console.log('TokenManager Address Matches: ', tokenMgmtContractAddress==this.TokenManagementContractAddress)
      let tokenManagerContract = new this.ethers.Contract(
        this.TokenManagementContractAddress, 
        abis['TokenManagement'].abi, 
        this.signer
      )
      console.log('Am I TokenManager Administrator: ', await tokenManagerContract.isAdministrator(this.ethereumAddress))
      console.log('Is TransactionManager an Administrator: ', await tokenManagerContract.isAdministrator(txnManagerAddress))
      console.log('Verify Correct TransactionManager: ', await tokenManagerContract.getTransactionManagerAddress() == txnManagerAddress && this.TransactionManagementContractAddress == txnManagerAddress)

      let cryptoravesTokenAddress = await transactionManagerContract.getCryptoravesTokenAddress()
      console.log('CryptoravesToken Address Matches: ', cryptoravesTokenAddress==this.CryptoravesTokenContractAddress)
      let cryptoravesTokenContract = new this.ethers.Contract(
        cryptoravesTokenAddress, 
        abis['CryptoravesToken'].abi, 
        this.signer
      )
      console.log('Am I CryptoravesToken Administrator: ', await cryptoravesTokenContract.isAdministrator(this.ethereumAddress))
      console.log('Is TokenManager an Administrator: ', await cryptoravesTokenContract.isAdministrator(tokenMgmtContractAddress))
      console.log('CryptoravesToken URI Matches: ',await cryptoravesTokenContract.uri(0) == this.uri)

      let userContractAddress = await transactionManagerContract.getUserManagementAddress()
      console.log('UserManager Address Matches: ', userContractAddress==this.UserManagementContractAddress)
      let userManagerContract = new this.ethers.Contract(
        userContractAddress, 
        abis['UserManagement'].abi, 
        this.signer
      )
      console.log('Am I UserManager Administrator: ', await userManagerContract.isAdministrator(this.ethereumAddress))
      console.log('Is TransactionManager an Administrator: ', await userManagerContract.isAdministrator(txnManagerAddress))
      console.log('Verify Correct TransactionManager: ', await tokenManagerContract.getTransactionManagerAddress() == txnManagerAddress && this.TransactionManagementContractAddress == txnManagerAddress)

      console.log('Contract UserManager Admin Configuration Is Correct:', await userManagerContract.testDownstreamAdminConfiguration())
      console.log('Contract CryptoravesToken Admin Configuration Is Correct:', await cryptoravesTokenContract.testDownstreamAdminConfiguration())
      console.log('Contract TokenManager Admin Configuration Is Correct:', await tokenManagerContract.testDownstreamAdminConfiguration())
      console.log('Contract TransactionManager Admin Configuration Is Correct:', await transactionManagerContract.testDownstreamAdminConfiguration())
      console.log('Contract Validator Admin Configuration Is Correct:', await contract.testDownstreamAdminConfiguration())

    },
    async launchERC20(){
      this.showLoading = true
      let factory = new this.ethers.ContractFactory(abis['ERC20Full'].abi, abis["ERC20Full"].bytecode, this.signer);
      let contract = await factory.deploy(
        this.ethereumAddress, 
        'TestXToken', 'TSTX', '18',
        '1000000000000000000000000000' //1 billion
      )

      let amount1 = await contract.balanceOf(this.ethereumAddress)
      console.log('ERC20 Token Launched With Balance: ', this.ethers.utils.formatEther(amount1))

      this.ERC20FullAddress = localStorage.ERC20FullAddress = contract.address

      this.showLoading = false
    },
    async depositAndSendToken(){

      let cryptoravesTokenContract = new this.ethers.Contract(this.CryptoravesTokenContractAddress, abis['CryptoravesToken'], this.signer)

      let amount1 = await cryptoravesTokenContract.balanceOf(this.ethereumAddress, this.tokenId)
      
      console.log('Balance #1: ', this.launchedWalletAddress, this.ethers.utils.formatUnits(amount1, 18))
      if (this.recipientAddress){
        let amount2 = await cryptoravesTokenContract.balanceOf(this.recipientAddress, this.tokenId)
        console.log('Balance #2: ', this.recipientAddress, this.ethers.utils.formatUnits(amount2, 18))
      }
      
      let randomRecipientTwitterId = Math.round(Math.random() * 1000000000)
      let twitterIds = [this.twitterId.toString(), randomRecipientTwitterId.toString(), '0']
      let twitterNames = ['@fakeHandle', '@randomFake2', '']

      let validatorContract = new this.ethers.Contract(
        this.ValidatorContractAddress, 
        this.abi, 
        this.signer
      )
      let tx = await validatorContract.validateCommand(
        twitterIds, twitterNames, '', false, 
        this.ethers.utils.parseEther(this.amount.toString()), 
        this.ethers.utils.formatBytes32String(this.data)
      )
      this.showLoading = true
      let val = await tx.wait()
      this.showLoading = false
      amount1 = await cryptoravesTokenContract.balanceOf(this.launchedWalletAddress, this.tokenId)

      abi = [
        'function getUserManagementAddress() public view returns(address)'
      ]
      let tokenManager = new this.ethers.Contract(this.managerContractAddress, abi, this.signer)

      let userContractAddress = await tokenManager.getUserManagementAddress()
      console.log('UserManager Address: '+userContractAddress)

      let userManagerContract = new this.ethers.Contract(
        userContractAddress, 
        this.userManagementABI, 
        this.signer
      )

      this.recipientAddress = this.managedContractRecipientAddress = await userManagerContract.getUserAccount(randomRecipientTwitterId);
      console.log(this.recipientAddress)
      console.log('Balance #1: ', this.launchedWalletAddress, this.ethers.utils.formatUnits(amount1, 18))
      
      amount1 = await cryptoravesTokenContractAddress.balanceOf(this.recipientAddress, this.tokenId)
      console.log('Balance #2: ', this.recipientAddress, this.ethers.utils.formatUnits(amount1, 18))
    },
    async depositERC20(){
      let token = new this.ethers.Contract(this.ERC20FullAddress, abis['ERC20Full'].abi, this.signer)
      let amount1 = await token.balanceOf(this.ethereumAddress)
      
      this.showLoading = true

      let cryptoravesToken = new this.ethers.Contract(
        this.CryptoravesTokenContractAddress, 
        abis['CryptoravesToken'].abi, 
        this.signer
      )

      let initialBalance 
      initialBalance = await cryptoravesToken.balanceOf(this.ethereumAddress, this.ERC1155tokenId)
      //console.log('ERC20 Amount before deposit: '+this.ethers.utils.formatUnits(amount1, 18))

      let tokenManagerContract = new this.ethers.Contract(
        this.TokenManagementContractAddress, 
        abis['TokenManagement'].abi, 
        this.signer
      )

      let randAmount = Math.round((Math.random() * 10 + Number.EPSILON) * 100) / 100
      //console.log('Random Amount: ', randAmount)
      let appr = await token.approve(this.TokenManagementContractAddress, this.ethers.utils.parseEther(randAmount.toString()));
      await appr.wait()

      let tx = await tokenManagerContract.deposit(
        this.ethers.utils.parseEther(randAmount.toString()),
        this.ERC20FullAddress,
        20,
        false
      )

      let val = await tx.wait()

      amount1 = await token.balanceOf(this.ethereumAddress)
      //console.log('ERC20 Amount After deposit: '+this.ethers.utils.formatUnits(amount1, 18))

      this.ERC1155tokenId = localStorage.ERC1155tokenId = await tokenManagerContract.getManagedTokenIdByAddress(this.ERC20FullAddress)
      //console.log('ERC1155 Token ID: '+this.ERC1155tokenId)
      
      let finalBalance = await cryptoravesToken.balanceOf(this.ethereumAddress, this.ERC1155tokenId)
      /*console.log('ERC1155 Wrapped amount received: '+this.ethers.utils.formatUnits(finalBalance, 18))
      console.log(Math.round(this.ethers.utils.formatUnits(initialBalance, 18) * 100) / 100)
      console.log(randAmount)
      console.log(Math.round(this.ethers.utils.formatUnits(finalBalance, 18) * 100 ) / 100)
      console.log(Math.round((this.ethers.utils.formatUnits(initialBalance, 18) * 1 + randAmount) * 100) / 100)
      */
      console.log(
        "Deposit of Random Amount Successful: ", 
        (Math.round((this.ethers.utils.formatUnits(initialBalance, 18) * 1 + randAmount) * 100) / 100).toString() == 
        (Math.round(this.ethers.utils.formatUnits(finalBalance, 18) * 100 ) / 100).toString()
      )

      this.showLoading = false
    },
    resetLocalStorage(){
      localStorage.removeItem('UserManagementContractAddress')
      localStorage.removeItem('TokenManagementContractAddress')
      localStorage.removeItem('CryptoravesTokenContractAddress')
      localStorage.removeItem('TransactionManagementContractAddress')
      localStorage.removeItem('ValidatorContractAddress')
      localStorage.removeItem('ERC20FullAddress')
      localStorage.removeItem('ERC1155tokenId')
      location.reload()
    },
    goEtherscan(param){
      if (param.length == 42){
        window.open(this.blockExplorerUrl+'address/'+param)
      }else{
        window.open(this.blockExplorerUrl+'tx/'+param)
      }
    },
    linkLibrary(bytecode, libraryName, libraryAddress) {
      const address = libraryAddress.replace('0x', '');
      const pattern = new RegExp(`_+${libraryName}_+`, 'g');
      if (!pattern.test(bytecode)) {
          throw new Error(`Can't link '${libraryName}'.`);
      }
      return bytecode.replace(pattern, address);
    }
  }
}
</script>

<style>
.container {
  margin: 0 auto;
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  text-align: center;
}

.title {
  font-family: 'Quicksand', 'Source Sans Pro', -apple-system, BlinkMacSystemFont,
    'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
  display: block;
  font-weight: 300;
  font-size: 100px;
  color: #35495e;
  letter-spacing: 1px;
}

.subtitle {
  font-weight: 300;
  font-size: 42px;
  color: #526488;
  word-spacing: 5px;
  padding-bottom: 15px;
}

.links {
  padding-top: 15px;
}
.error {
    color: red;
}
a:hover {
  cursor: pointer;
  color: blue;
  font-weight: bold;
}
</style>
