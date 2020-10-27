<template>
  <div 
    class="container"
  >
    <div v-if="ready">
      <div v-if='loadNetworkData()'></div>
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
        For Deploying, Administering Contract Upgrades, and End User Support
      </h2>
    </div>
    <div v-if="ready && !showLoading">
      <div class="links">
        <br>
        <a
          target="_blank" 
          @click="goEtherscan(ethereumAddress)">
          Your Wallet Address:<br> {{ this.ethereumAddress }}
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
              User Management Contract Address:<br> {{ this.UserManagementContractAddress }}
            </a>
            <a
              @click="relaunch('UserManagement')"
              class="button--green"
            >
              Re-Launch
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
              Token Management Contract Address:<br> {{ this.TokenManagementContractAddress }}
            </a>
            <a
              @click="relaunch('TokenManagement')"
              class="button--green"
            >
              Re-Launch
            </a>
        </div>
        <div
            v-if="CryptoravesTokenContractAddress && !showLoading" 
            class="links">
          <a
            target="_blank"
            @click="goEtherscan(CryptoravesTokenContractAddress)">
            Cryptoraves Token Contract Address:<br> {{ this.CryptoravesTokenContractAddress }}
          </a>
          <a
            @click="relaunch('CryptoravesToken')"
            class="button--green"
          >
            Re-Launch
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
              @click="goEtherscan(AdminToolsLibraryAddress)">
              Admin Tools Library Contract Address:<br>{{ this.AdminToolsLibraryAddress }}
            </a>
            <br><br>
            <a
              target="_blank"
              @click="goEtherscan(TransactionManagementContractAddress)">
              Transaction Management Contract Address:<br>{{ this.TransactionManagementContractAddress }}
            </a>
            <a
              @click="relaunch('TransactionManagement')"
              class="button--green"
            >
              Re-Launch
            </a>
        </div>
        <div
          v-if="TransactionManagementContractAddress && !ValidatorInterfaceContractAddress && !showLoading" 
          class="links">
          <a
            @click="launchValidatorContract()"
            class="button--green"
          >
            Launch Validator Contract
          </a>
        </div>
        <div
          v-if="TransactionManagementContractAddress && ValidatorInterfaceContractAddress"
          class="links">
            <a
              target="_blank"
              @click="goEtherscan(ValidatorInterfaceContractAddress)">
              Validator Contract Address:<br> {{ this.ValidatorInterfaceContractAddress }}
            </a>
            <a
              @click="relaunch('ValidatorInterface')"
              class="button--green"
            >
              Re-Launch
            </a>
        </div>
        <div
          class="links">
          <a
            v-if="ValidatorInterfaceContractAddress"
            @click="testVariables()"
            class="button--green"
          >
            Test Admin Functions
          </a>
        </div> 
        <div
          class="links">
          <a
            v-if="ValidatorInterfaceContractAddress && ! ERC20FullAddress"
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
              Test ERC20 Contract Address:<br> {{ this.ERC20FullAddress }}
          </a>
          <br>
          <a
            
            @click="depositERC20()"
            class="button--green"
          >
            Deposit Test ERC20 Tokens
          </a>
          <br>
          <a
            
            @click="setEmoji()"
            class="button--green"
          >
            Set Emoji For ERC20 🔥
          </a>
          <br><br>
        </div> 
        <div
          v-if="ERC20FullAddress"
          class="links">
          <input v-model="depositAndSendERC20address">
          <br><br>
          <a
            
            @click="depositAndSendERC20()"
            class="button--green"
          >
            Send 1000 ERC20's To Above Address
          </a>
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

          <div 
            v-if="UserManagementContractAddress && TokenManagementContractAddress && CryptoravesTokenContractAddress && TransactionManagementContractAddress && ValidatorInterfaceContractAddress"
            class="links">
            <br>
            <br>
            <a
              @click="exportContractStructureForThisNetwork(true)"
              class="button--green"
            >
              Save Network Settings
            </a>
          </div>
          <div 
            class="links">
            <br>
            <br>
            <a
              @click="importContractStructureForThisNetwork(true)"
              class="button--green"
            >
              Load Network Settings
            </a>
          </div>

      </div>
    </div>
    <div
      v-if="showLoading"
      >
        <img 
          src="../assets/gif/loading.gif" 
          alt >
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
      ready: true,
      uri: 'http://a.b.com',
      UserManagementContractAddress: null,
      UserManagementContractAddress: null,
      TokenManagementContractAddress: null,
      CryptoravesTokenContractAddress: null,
      TransactionManagementContractAddress: null,
      ValidatorInterfaceContractAddress: null,
      ERC20FullAddress: null,
      ERC1155tokenId: 0,
      showLoading: false,
      depositAndSendERC20address: '0xabc...'
    }
  },
  created() {
    this.checkAbis()

  },
  mounted() {
    
    /*if (localStorage.CryptoravesTokenContractAddress) this.CryptoravesTokenContractAddress = localStorage.CryptoravesTokenContractAddress
    if (localStorage.UserManagementContractAddress) this.UserManagementContractAddress = localStorage.UserManagementContractAddress
    if (localStorage.TokenManagementContractAddress) this.TokenManagementContractAddress = localStorage.TokenManagementContractAddress
    if (localStorage.TransactionManagementContractAddress) this.TransactionManagementContractAddress = localStorage.TransactionManagementContractAddress
    if (localStorage.ValidatorInterfaceContractAddress) this.ValidatorInterfaceContractAddress = localStorage.ValidatorInterfaceContractAddress 

    if (localStorage.ERC20FullAddress) this.ERC20FullAddress = localStorage.ERC20FullAddress
    if (localStorage.AdminToolsLibraryAddress) this.AdminToolsLibraryAddress = localStorage.AdminToolsLibraryAddress

    if (localStorage.uri) this.uri = localStorage.uri
*/
  },
  methods: {
    loadNetworkData(){
      console.log(this.networkType)
      if(this.networkType){
        this.importContractStructureForThisNetwork(false)
        return true
      }
    },
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
      
      this.AdminToolsLibraryAddress = localStorage.AdminToolsLibraryAddress = contract.address

      console.log('AdminToolsContract Address:', contract.address)
      let bytecode = this.linkLibrary(abis["TransactionManagement"].bytecode, 'AdminToolsLibrary', contract.address)
      
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
      
      this.ValidatorInterfaceContractAddress = localStorage.ValidatorInterfaceContractAddress = contract.address

      //set as admin of transaction Manager
      let transactionManagement = new this.ethers.Contract(
        this.TransactionManagementContractAddress, 
        abis["TransactionManagement"].abi, 
        this.signer
      )
      try{
        await transactionManagement.setAdministrator(this.ValidatorInterfaceContractAddress)
        if(
          await contract.isAdministrator(this.ValidatorInterfaceContractAddress)
        ){
          console.log('Set Admin For Transaction Manager')
        }
      } catch(e) {
        throw new Error(e)
      }
      this.showLoading = false
      //test for proper admin configuration
      await this.testVariables()
    },
    async relaunch(contractName){
      this.showLoading = true
      let factory, bytecode
      let contractAddressVariableName = contractName+'ContractAddress'
      if (contractName == 'ValidatorInterface'){
        contractName='ValidatorInterfaceContract'
      }
      if (contractName == 'TransactionManagement'){
        //must link library first
        factory = new this.ethers.ContractFactory(abis["AdminToolsLibrary"].abi, abis["AdminToolsLibrary"].bytecode, this.signer);
        let adminToolsLibraryContract = await factory.deploy()
        bytecode = this.linkLibrary(abis["TransactionManagement"].bytecode, 'AdminToolsLibrary', adminToolsLibraryContract.address)
      }else{
        bytecode = abis[contractName].bytecode
      }

      
      factory = new this.ethers.ContractFactory(abis[contractName].abi, bytecode, this.signer);
      
      let oldContractAddress = this[contractAddressVariableName]
      let oldAdminAddress, contract, tx
      let transactionManagement = new this.ethers.Contract(
        this.TransactionManagementContractAddress, 
        abis["TransactionManagement"].abi, 
        this.signer
      )
      let tokenManagement = new this.ethers.Contract(
        this.TokenManagementContractAddress, 
        abis["TokenManagement"].abi, 
        this.signer
      )

      switch(contractName){
        case 'UserManagement':
          console.log('Launching new contract..') //1a
          contract = await factory.deploy();
          tx = await contract.deployed()
          //set new address
          this[contractAddressVariableName] = localStorage[contractAddressVariableName] = contract.address
          
          console.log('setting new upstream contract TransactionManagement as admin..')
          tx = await contract.setAdministrator(this.TransactionManagementContractAddress)
          await tx.wait()
          
          console.log('setting new downstram address for admin contract "setUserManagementAddress"')
          tx = await transactionManagement.setUserManagementAddress(this[contractAddressVariableName])  
          await tx.wait()
        break;
        case 'TokenManagement':
          contract = await factory.deploy('https://x.y.zom');
          tx = await contract.deployed()
          //set new address
          this[contractAddressVariableName] = localStorage[contractAddressVariableName] = contract.address

          console.log('setting new upstream contract TransactionManagement as admin..') //1b
          tx = await contract.setAdministrator(this.TransactionManagementContractAddress)
          await tx.wait()

          console.log('setting legacy downstream Cryptoraves contract addr..') //1c
          tx = await contract.setCryptoravesTokenAddress(this.CryptoravesTokenContractAddress)
          await tx.wait()
          
          let cryptoravesTokenContract = new this.ethers.Contract(
            this.CryptoravesTokenContractAddress, 
            abis['CryptoravesToken'].abi, 
            this.signer
          )
          console.log('setting new downstream admin') //2
          tx = await cryptoravesTokenContract.setAdministrator(this[contractAddressVariableName])
          await tx.wait()

          console.log('setting new downstream address for admin contract') //3
          tx = await transactionManagement.setTokenManagementAddress(this[contractAddressVariableName])  
          await tx.wait()

          console.log('unsetting old downstream admin') //4
          tx = await cryptoravesTokenContract.unsetAdministrator(oldContractAddress)
          await tx.wait()
        break;
        case 'CryptoravesToken':
          console.log('Launching new contract..') //1a

          this.uri = localStorage.uri = 'https://rando.'+Math.floor(Math.random() * Math.floor(9999)).toString()+'.com'
          contract = await factory.deploy(this.uri);
          tx = await contract.deployed()
          //set new address
          this[contractAddressVariableName] = localStorage[contractAddressVariableName] = contract.address
          
          console.log('setting new upstream contract TokenManagement as admin..')
          tx = await contract.setAdministrator(this.TokenManagementContractAddress)
          await tx.wait()
          
          console.log('setting new downstram address for admin contract "setCryptoravesTokenAddress"')
          tx = await tokenManagement.setCryptoravesTokenAddress(this[contractAddressVariableName])  
          await tx.wait()
        break;
        case 'TransactionManagement':
          contract = await factory.deploy(this.TokenManagementContractAddress, this.UserManagementContractAddress);
          tx = await contract.deployed()
          //set new address
          this[contractAddressVariableName] = localStorage[contractAddressVariableName] = contract.address

          console.log('setting new upstream contract TransactionManagement as admin..') //1b
          tx = await contract.setAdministrator(this.ValidatorInterfaceContractAddress)
          await tx.wait()

          let userManagement = new this.ethers.Contract(
            this.UserManagementContractAddress, 
            abis['UserManagement'].abi, 
            this.signer
          )
          console.log('setting new downstream admins') //2
          tx = await tokenManagement.setAdministrator(this[contractAddressVariableName])
          await tx.wait()
          tx = await userManagement.setAdministrator(this[contractAddressVariableName])
          await tx.wait()

          let validatorContract = new this.ethers.Contract(
            this.ValidatorInterfaceContractAddress, 
            abis['ValidatorInterfaceContract'].abi, 
            this.signer
          )
          console.log('setting new downstream address for admin contract') //3
          tx = await validatorContract.setTransactionManagementAddress(this[contractAddressVariableName])  
          await tx.wait()

          console.log('unsetting old downstream admins') //4
          tx = await tokenManagement.unsetAdministrator(oldContractAddress)
          await tx.wait()
          tx = await userManagement.unsetAdministrator(oldContractAddress)
          await tx.wait()
        break;
        case 'ValidatorInterfaceContract':
          console.log('Launching new contract..') //1a
          contract = await factory.deploy(this.TransactionManagementContractAddress);
          tx = await contract.deployed()
          //set new address
          this[contractAddressVariableName] = localStorage[contractAddressVariableName] = contract.address
          
          console.log('setting new downstream admin')
          tx = await transactionManagement.setAdministrator(this[contractAddressVariableName])  
          await tx.wait()
        break;
      }

      //test for proper admin configuration
      await this.testVariables()

      this.showLoading = false
    },
    async testVariables(){
      
      this.exportContractStructureForThisNetwork(false)

      let res, cumulativeBool
      let contract = new this.ethers.Contract(
        this.ValidatorInterfaceContractAddress, 
        abis['ValidatorInterfaceContract'].abi, 
        this.signer
      )
      
      cumulativeBool = res = await contract.isAdministrator(this.ethereumAddress)
      console.log('Am I ValidatorInterfaceContract Administrator:', res)
      let txnManagerAddress = await contract.getTransactionManagementAddress()
      res = txnManagerAddress==this.TransactionManagementContractAddress
      cumulativeBool = cumulativeBool && res
      console.log('TransactionManager Address Matches:', res)

      let transactionManagerContract = new this.ethers.Contract(
        txnManagerAddress, 
        abis['TransactionManagement'].abi, 
        this.signer
      )
      res = await transactionManagerContract.isAdministrator(this.ethereumAddress)
      cumulativeBool = cumulativeBool && res
      console.log('Am I TransactionManagement Administrator: ', res)
      res = await transactionManagerContract.isAdministrator(this.ValidatorInterfaceContractAddress)
      cumulativeBool = cumulativeBool && res
      console.log('Is ValidatorInterfaceContract an Administrator: ', res)

      let tokenMgmtContractAddress = await transactionManagerContract.getTokenManagementAddress()
      res = tokenMgmtContractAddress==this.TokenManagementContractAddress
      cumulativeBool = cumulativeBool && res
      console.log('TokenManager Address Matches: ', res)
      let tokenManagerContract = new this.ethers.Contract(
        this.TokenManagementContractAddress, 
        abis['TokenManagement'].abi, 
        this.signer
      )
      res = await tokenManagerContract.isAdministrator(this.ethereumAddress)
      cumulativeBool = cumulativeBool && res
      console.log('Am I TokenManager Administrator: ', res)
      res = await tokenManagerContract.isAdministrator(txnManagerAddress)
      cumulativeBool = cumulativeBool && res
      console.log('Is TransactionManager an Administrator: ', res)
      res = await tokenManagerContract.getTransactionManagerAddress() == txnManagerAddress && this.TransactionManagementContractAddress == txnManagerAddress
      cumulativeBool = cumulativeBool && res
      console.log('Verify Correct TransactionManager 1: ', res)

      let cryptoravesTokenAddress = await transactionManagerContract.getCryptoravesTokenAddress()
      res = cryptoravesTokenAddress==this.CryptoravesTokenContractAddress
      cumulativeBool = cumulativeBool && res
      console.log('CryptoravesToken Address Matches: ', res)
      let cryptoravesTokenContract = new this.ethers.Contract(
        cryptoravesTokenAddress, 
        abis['CryptoravesToken'].abi, 
        this.signer
      )
      res = await cryptoravesTokenContract.isAdministrator(this.ethereumAddress)
      cumulativeBool = cumulativeBool && res
      console.log('Am I CryptoravesToken Administrator: ', res)
      res = await cryptoravesTokenContract.isAdministrator(tokenMgmtContractAddress)
      cumulativeBool = cumulativeBool && res
      console.log('Is TokenManager an Administrator: ', res)
      res = await cryptoravesTokenContract.uri(0) == this.uri
      cumulativeBool = cumulativeBool && res
      console.log('CryptoravesToken URI Matches: ',res)

      let userContractAddress = await transactionManagerContract.getUserManagementAddress()
      res = userContractAddress==this.UserManagementContractAddress
      cumulativeBool = cumulativeBool && res
      console.log('UserManager Address Matches: ', res)
      let userManagerContract = new this.ethers.Contract(
        userContractAddress, 
        abis['UserManagement'].abi, 
        this.signer
      )
      res = await userManagerContract.isAdministrator(this.ethereumAddress)
      cumulativeBool = cumulativeBool && res
      console.log('Am I UserManager Administrator: ', res)
      res = await userManagerContract.isAdministrator(txnManagerAddress)
      cumulativeBool = cumulativeBool && res
      console.log('Is TransactionManager an Administrator: ', res)
      res = await tokenManagerContract.getTransactionManagerAddress() == txnManagerAddress && this.TransactionManagementContractAddress == txnManagerAddress
      cumulativeBool = cumulativeBool && res
      console.log('Verify Correct TransactionManager 2: ', res)

      res = await userManagerContract.testDownstreamAdminConfiguration()
      cumulativeBool = cumulativeBool && res
      console.log('Contract UserManager Admin Configuration Is Correct:', res)
      res = await cryptoravesTokenContract.testDownstreamAdminConfiguration()
      cumulativeBool = cumulativeBool && res
      console.log('Contract CryptoravesToken Admin Configuration Is Correct:', res)
      res = await tokenManagerContract.testDownstreamAdminConfiguration()
      cumulativeBool = cumulativeBool && res
      console.log('Contract TokenManager Admin Configuration Is Correct:', res)
      res = await transactionManagerContract.testDownstreamAdminConfiguration()
      cumulativeBool = cumulativeBool && res
      console.log('Contract TransactionManager Admin Configuration Is Correct:', res)
      res = await contract.testDownstreamAdminConfiguration()
      cumulativeBool = cumulativeBool && res
      console.log('Contract Validator Admin Configuration Is Correct:', res)
      if( ! cumulativeBool){
        alert('Error running admin tests. Check for "false" in console logs')
      }

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
      console.log('ERC20 Amount before deposit: '+this.ethers.utils.formatUnits(amount1, 18))

      let tokenManagerContract = new this.ethers.Contract(
        this.TokenManagementContractAddress, 
        abis['TokenManagement'].abi, 
        this.signer
      )

      let randAmount = Math.round((Math.random() * 10 + Number.EPSILON) * 100) / 100
      console.log('Random Amount: ', randAmount)
      let appr = await token.approve(this.TokenManagementContractAddress, this.ethers.utils.parseEther(randAmount.toString()));
      await appr.wait()
      console.log('here')
      let tx = await tokenManagerContract.deposit(
        this.ethers.utils.parseEther(randAmount.toString()),
        this.ERC20FullAddress,
        20,
        false
      )

      let val = await tx.wait()

      amount1 = await token.balanceOf(this.ethereumAddress)
      console.log('ERC20 Amount After deposit: '+this.ethers.utils.formatUnits(amount1, 18))

      this.ERC1155tokenId = localStorage.ERC1155tokenId = await tokenManagerContract.getManagedTokenIdByAddress(this.ERC20FullAddress)
      console.log('ERC1155 Token ID: '+this.ERC1155tokenId)
      
      let finalBalance = await cryptoravesToken.balanceOf(this.ethereumAddress, this.ERC1155tokenId)
      console.log('ERC1155 Wrapped amount received: '+this.ethers.utils.formatUnits(finalBalance, 18))
      console.log(Math.round(this.ethers.utils.formatUnits(initialBalance, 18) * 100) / 100)
      console.log(randAmount)
      console.log(Math.round(this.ethers.utils.formatUnits(finalBalance, 18) * 100 ) / 100)
      console.log(Math.round((this.ethers.utils.formatUnits(initialBalance, 18) * 1 + randAmount) * 100) / 100)
      
      console.log(
        "Deposit of Random Amount Successful: ", 
        (Math.round((this.ethers.utils.formatUnits(initialBalance, 18) * 1 + randAmount) * 100) / 100).toString() == 
        (Math.round(this.ethers.utils.formatUnits(finalBalance, 18) * 100 ) / 100).toString()
      )

      this.showLoading = false
    },
    async setEmoji(){
      let tokenManagerContract = new this.ethers.Contract(
        this.TokenManagementContractAddress, 
        abis['TokenManagement'].abi, 
        this.signer
      )
      let addr = await tokenManagerContract.getManagedTokenIdByAddress(this.ERC20FullAddress)
      let res = await tokenManagerContract.setEmoji(addr,'🔥')
      console.log(res)

    },
    async depositAndSendERC20(){
      let token = new this.ethers.Contract(this.ERC20FullAddress, abis['ERC20Full'].abi, this.signer)
      
      this.showLoading = true

      let cryptoravesToken = new this.ethers.Contract(
        this.CryptoravesTokenContractAddress, 
        abis['CryptoravesToken'].abi, 
        this.signer
      )
      
      let tokenManagerContract = new this.ethers.Contract(
        this.TokenManagementContractAddress, 
        abis['TokenManagement'].abi, 
        this.signer
      )
     
      this.ERC1155tokenId = localStorage.ERC1155tokenId = await tokenManagerContract.getManagedTokenIdByAddress(this.ERC20FullAddress)
      let initialBalance = await cryptoravesToken.balanceOf(this.depositAndSendERC20address, this.ERC1155tokenId)
      let amount = 1000
      let appr = await token.approve(this.TokenManagementContractAddress, this.ethers.utils.parseEther(amount.toString()));
      await appr.wait()
      let tx = await tokenManagerContract.deposit(
        this.ethers.utils.parseEther(amount.toString()),
        this.ERC20FullAddress,
        20,
        false
      )

      let val = await tx.wait()

      //transfer
      let cryptoravesTokenContract = new this.ethers.Contract(
        this.CryptoravesTokenContractAddress,
        abis['CryptoravesToken'].abi, 
        this.signer
      )
      
      tx = await cryptoravesTokenContract.safeTransferFrom(
        this.ethereumAddress,
        this.depositAndSendERC20address,
        this.ERC1155tokenId,
        this.ethers.utils.parseEther(amount.toString()),
        this.ethers.utils.formatBytes32String('')
      )
      val = await tx.wait()

      let finalBalance = await cryptoravesToken.balanceOf(this.depositAndSendERC20address, this.ERC1155tokenId)
      
      
      console.log(
        "Deposit and send of 1000 tokens Successful: ", 
        (Math.round((this.ethers.utils.formatUnits(initialBalance, 18) * 1 + amount) * 100) / 100).toString(), 
        (Math.round(this.ethers.utils.formatUnits(finalBalance, 18) * 100 ) / 100).toString()
      )

      this.showLoading = false
    },
    importContractStructureForThisNetwork(alertsBool){
      let savedNetwork = {}
      if(localStorage.networkInfo){
        let networkInfo = JSON.parse(localStorage.networkInfo)
        if(networkInfo[this.networkType]){
          savedNetwork[this.networkType] = networkInfo[this.networkType]
        }else{
          if(alertsBool){
            alert('No Saved Network Info for '+this.networkType)
          }
          return 0
        }
      }
      if(this.networkType == savedNetwork[this.networkType]["networkType"]){
        
        this.UserManagementContractAddress = localStorage.UserManagementContractAddress = savedNetwork[this.networkType]["UserManagementContractAddress"]
        this.TokenManagementContractAddress = localStorage.TokenManagementContractAddress = savedNetwork[this.networkType]["TokenManagementContractAddress"]
        this.CryptoravesTokenContractAddress = localStorage.CryptoravesTokenContractAddress = savedNetwork[this.networkType]["CryptoravesTokenContractAddress"]
        this.TransactionManagementContractAddress = localStorage.TransactionManagementContractAddress = savedNetwork[this.networkType]["TransactionManagementContractAddress"]
        this.ValidatorInterfaceContractAddress = localStorage.ValidatorInterfaceContractAddress = savedNetwork[this.networkType]["ValidatorInterfaceContractAddress"]
        if(savedNetwork["ERC20FullAddress"]){
          this.ERC20FullAddress = localStorage.ERC20FullAddress = savedNetwork[this.networkType]["ERC20FullAddress"]
        }
        this.ERC1155tokenId = localStorage.ERC1155tokenId = savedNetwork[this.networkType]["ERC1155tokenId"]
        this.AdminToolsLibraryAddress = localStorage.AdminToolsLibraryAddress = savedNetwork[this.networkType]["AdminToolsLibraryAddress"]

      }else{
        if(alertsBool){
          alert('Network Name doesn\'t match. Cannot Save Info.', this.networkType, savedNetwork[this.networkType]["networkType"])
        }
      }
    },
    exportContractStructureForThisNetwork(alertsBool){
      if(this.networkType){
        
        //if localsotrage.networkName is set then prompt for overwrite confirmation
        let savedNetwork = {}
        savedNetwork["networkType"] = this.networkType
        savedNetwork["UserManagementContractAddress"] = this.UserManagementContractAddress
        savedNetwork["TokenManagementContractAddress"] = this.TokenManagementContractAddress
        savedNetwork["CryptoravesTokenContractAddress"] = this.CryptoravesTokenContractAddress
        savedNetwork["TransactionManagementContractAddress"] = this.TransactionManagementContractAddress
        savedNetwork["ValidatorInterfaceContractAddress"] = this.ValidatorInterfaceContractAddress
        if (this.ERC20FullAddress){
          savedNetwork["ERC20FullAddress"] = this.ERC20FullAddress
        }
        savedNetwork["ERC1155tokenId"] = this.ERC1155tokenId
        savedNetwork["AdminToolsLibraryAddress"]  = this.AdminToolsLibraryAddress
        
        let networkInfo = {}
        if(localStorage.networkInfo){
          networkInfo = JSON.parse(localStorage.networkInfo)
        } 
        networkInfo[this.networkType] = savedNetwork
        localStorage.networkInfo = JSON.stringify(networkInfo)

        if(alertsBool){
          this.copyToClipboard(JSON.stringify(savedNetwork))
          alert('Network Info Saved for '+this.networkType+ ' and copied to clipboard')
        }else{
          console.log('Network Info Saved for '+this.networkType+ ' and copied to clipboard')
        }

      }else{
        alert('No Network Name. Cannot Export Info.')
      }
    },
    copyToClipboard(text) {
        if (window.clipboardData && window.clipboardData.setData) {
            // Internet Explorer-specific code path to prevent textarea being shown while dialog is visible.
            return clipboardData.setData("Text", text);

        }
        else if (document.queryCommandSupported && document.queryCommandSupported("copy")) {
            var textarea = document.createElement("textarea");
            textarea.textContent = text;
            textarea.style.position = "fixed";  // Prevent scrolling to bottom of page in Microsoft Edge.
            document.body.appendChild(textarea);
            textarea.select();
            try {
                return document.execCommand("copy");  // Security exception may be thrown by some browsers.
            }
            catch (ex) {
                console.warn("Copy to clipboard failed.", ex);
                return false;
            }
            finally {
                document.body.removeChild(textarea);
            }
        }
    },
    resetLocalStorage(){
      localStorage.removeItem('UserManagementContractAddress')
      localStorage.removeItem('TokenManagementContractAddress')
      localStorage.removeItem('CryptoravesTokenContractAddress')
      localStorage.removeItem('TransactionManagementContractAddress')
      localStorage.removeItem('ValidatorInterfaceContractAddress')
      localStorage.removeItem('ERC20FullAddress')
      localStorage.removeItem('ERC1155tokenId')
      localStorage.removeItem('AdminToolsLibrary')
      if(localStorage.networkInfo){
        let netdata = JSON.parse(localStorage.networkInfo)
        if(netdata.hasOwnProperty(this.networkType)){
          delete netdata[this.networkType]
          localStorage.networkInfo = JSON.stringify(netdata)
        }
      }
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
