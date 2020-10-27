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
        Web3 Portal Testing Page
      </h1>
      <h2 class="subtitle">
        For Testing And Developing Token Management System Through Web3
      </h2>
    </div>
    <div v-if="ready && !showLoading">
        <div v-if="ValidatorInterfaceContractAddress"
          class="links">
          <a
            target="_blank" 
            @click="goEtherscan(ethereumAddress)">
            
            Your Wallet Address:<br> {{ this.ethereumAddress }}
          </a>
          <br>
          <a
            
            @click="getBalances()"
            class="button--green"
          >
            Get Balances
          </a>
        </div> 
        <div v-else>
          Please Launch ValidatorInterface Contract in Administrators View
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
              Test ERC20 Contract Address:<br> {{ this.ERC20FullAddress }}<br>
          </a>
          <a  v-if="ERC20WrappedId > 0"
              target="_blank">
              Your ERC20 Wrapped ID: {{ this.ERC20WrappedId }}<br>
              
          </a>
          <a  v-if="ERC20balance"
              target="_blank">
              Your ERC20 Balance: {{ this.ERC20balance }}<br>
              
          </a>
          <a  v-if="ERC20balance && ERC20WrappedId > 0"
              target="_blank">
              Your ERC20 Wrapped Balance: {{ this.ERC20WrappedBalance }}<br>

          </a>
          <a  v-if="ERC20Emoji"
              target="_blank">
              ERC20 Emoji: {{ this.ERC20Emoji }}<br>
          </a>
          <a
            
            @click="depositERC20()"
            class="button--green"
          >
            Deposit Test ERC20 Tokens
          </a>
          <br>
          <a
            v-if="ERC20FullAddress"
            @click="launchERC20()"
            class="button--green"
          >
            Launch A New ERC20
          </a>
          <br>
        </div> 
        <div
          v-if="ERC20FullAddress && ERC20WrappedId"
          class="links">
          <input v-model="depositAndSendERC20address">
          <br><br>
          <a
            
            @click="sendWrappedERC20()"
            class="button--green"
          >
            Send Wrapped ERC20 To Above Address
          </a>
        </div>
        <div
          class="links">
          <a
            v-if="ValidatorInterfaceContractAddress && ! ERC721FullAddress"
            @click="launchERC721()"
            class="button--green"
          >
            Launch An ERC721
          </a>
        </div> 
        <div
          v-if="ERC721FullAddress"
          class="links">
          <a
              target="_blank"
              @click="goEtherscan(ERC721FullAddress)">
              Test ERC721 Contract Address:<br> {{ this.ERC721FullAddress }}<br>
          </a>
          <a  v-if="ERC721WrappedId > 0"
              target="_blank">
              Your ERC721 Wrapped ID: {{ this.ERC721WrappedId }}<br>
              
          </a>
          <a  v-if="ERC721balance"
              target="_blank"
              @click="goEtherscan(ERC721FullAddress)">
              Your ERC721 Balance: {{ this.ERC721balance }}<br>
          </a>
          <a  v-if="ERC721balance && ERC721WrappedId > 0"
              target="_blank">
              Your ERC721 Wrapped Balance: {{ this.ERC721WrappedBalance }}<br>
          </a>
          <a  v-if="ERC721Emoji"
              target="_blank">
              ERC721 Emoji: {{ this.ERC721Emoji }}
          </a>
          <br>
          <a 
              
              @click="mintERC721()"
              class="button--green"
          >
              Mint An ERC721 To YOur Wallet
          </a>
          <br>
          <a
            
            @click="depositERC721()"
            class="button--green"
          >
            Deposit Test ERC721 Tokens
          </a>
          <br><a
            v-if="ERC20FullAddress"
            @click="launchERC721()"
            class="button--green"
          >
            Launch A New ERC721
          </a><br><br>
        </div> 
        <div
          v-if="ERC721FullAddress && ERC721WrappedId"
          class="links">
          <input v-model="depositAndSendERC721address">
          <br><br>
          <a
            
            @click="sendWrappedERC721(0)"
            class="button--green"
          >
            Send An ERC721 To Above Address
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
              @click="exportContractStructureForThisNetwork()"
              class="button--green"
            >
              Export Network Settings
            </a>
          </div>
          <div 
            class="links">
            <br>
            <br>
            <a
              @click="importContractStructureForThisNetwork()"
              class="button--green"
            >
              Import Network Settings
            </a>
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
      ERC20balance: 0,
      ERC20WrappedBalance: 0,
      ERC20Emoji: '',
      ERC20WrappedId: 0,
      ERC721FullAddress: null,
      ERC721balance: 0,
      ERC721WrappedBalance: 0,
      ERC721Emoji: '',
      ERC721WrappedId: 0,
      showLoading: false,
      depositAndSendERC20address: '0xabc...',
      depositAndSendERC721address: '0x123...'
    }
  },
  created() {
    this.checkAbis()

  },
  mounted() {

 
    if (localStorage.CryptoravesTokenContractAddress) this.CryptoravesTokenContractAddress = localStorage.CryptoravesTokenContractAddress
    if (localStorage.UserManagementContractAddress) this.UserManagementContractAddress = localStorage.UserManagementContractAddress
    if (localStorage.TokenManagementContractAddress) this.TokenManagementContractAddress = localStorage.TokenManagementContractAddress
    if (localStorage.TransactionManagementContractAddress) this.TransactionManagementContractAddress = localStorage.TransactionManagementContractAddress
    if (localStorage.ValidatorInterfaceContractAddress) this.ValidatorInterfaceContractAddress = localStorage.ValidatorInterfaceContractAddress 

    if (localStorage.ERC20FullAddress) this.ERC20FullAddress = localStorage.ERC20FullAddress
    if (localStorage.ERC721FullAddress) {
      this.ERC721FullAddress = localStorage.ERC721FullAddress
    } 

    if (localStorage.AdminToolsLibraryAddress) this.AdminToolsLibraryAddress = localStorage.AdminToolsLibraryAddress

    if (localStorage.uri) this.uri = localStorage.uri

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
    async getBalances(){
      let baseTokenNFT = 12345 << 128
      console.log(baseTokenNFT)
      try {
        await this.getERC20Balance()
      }catch{
        console.log('Error with init getERC20Balance')
      }
      try {
        await this.getERC721Balance()
      }catch{
        console.log('Error with init getERC721Balance')
      }
      try {
        await this.getAllERC721sHeld()
      }catch{
        console.log('Error with init getAllERC721sHeld')
      }
      try {
        await this.getWrappedBalances()
      }catch{
        console.log('Error with init getWrappedBalances')
      }
      try {
        await this.getEmojis()
      }catch{
        console.log('Error with init getEmojis')
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

      this.ERC20balance = await contract.balanceOf(this.ethereumAddress)
      console.log('ERC20 Token Launched With Balance: ', this.ethers.utils.formatEther(this.ERC20balance))

      this.ERC20FullAddress = localStorage.ERC20FullAddress = contract.address

      

      //get new contract id
      let tokenManagerContract = new this.ethers.Contract(
        this.TokenManagementContractAddress, 
        abis['TokenManagement'].abi, 
        this.signer
      )
      let cryptoravesToken = new this.ethers.Contract(
        this.CryptoravesTokenContractAddress, 
        abis['CryptoravesToken'].abi, 
        this.signer
      )
      let ERC1155tokenIdForERC20 = await tokenManagerContract.getManagedTokenIdByAddress(this.ERC20FullAddress)
      this.ERC20WrappedBalance = this.ethers.utils.formatUnits(
        await cryptoravesToken.balanceOf(this.ethereumAddress, ERC1155tokenIdForERC20),
        18
      )
      this.ERC20WrappedId = ERC1155tokenIdForERC20

      this.getBalances()

      this.showLoading = false
    },
    async getWrappedBalances(){

      let tokenManagerContract = new this.ethers.Contract(
        this.TokenManagementContractAddress, 
        abis['TokenManagement'].abi, 
        this.signer
      )
      let cryptoravesToken = new this.ethers.Contract(
        this.CryptoravesTokenContractAddress, 
        abis['CryptoravesToken'].abi, 
        this.signer
      )
      let ERC1155tokenIdForERC20 = await tokenManagerContract.getManagedTokenIdByAddress(this.ERC20FullAddress)
      this.ERC20WrappedBalance = this.ethers.utils.formatUnits(
        await cryptoravesToken.balanceOf(this.ethereumAddress, ERC1155tokenIdForERC20),
        18
      )
      this.ERC20WrappedId = ERC1155tokenIdForERC20

      let ERC1155tokenIdForERC721 = await tokenManagerContract.getManagedTokenIdByAddress(this.ERC721FullAddress)
      this.ERC721WrappedBalance = await cryptoravesToken.balanceOf(this.ethereumAddress, ERC1155tokenIdForERC721)
      this.ERC721WrappedId = ERC1155tokenIdForERC721

    },
    async getEmojis(){
      let tokenManagerContract = new this.ethers.Contract(
        this.TokenManagementContractAddress, 
        abis['TokenManagement'].abi, 
        this.signer
      )
      this.ERC20Emoji = await tokenManagerContract.getEmoji(this.ERC20WrappedId)
      console.log(this.ERC20WrappedId.toString())
      console.log(this.ERC20Emoji)
      this.ERC721Emoji = await tokenManagerContract.getEmoji(this.ERC721WrappedId)
      console.log(this.ERC721WrappedId.toString())
      console.log(this.ERC721Emoji)
      console.log(await tokenManagerContract.getAddressBySymbol(this.ERC721Emoji))
    },
    async getERC20Balance(){
      let token = new this.ethers.Contract(this.ERC20FullAddress, abis['ERC20Full'].abi, this.signer)
      this.ERC20balance = this.ethers.utils.formatUnits(await token.balanceOf(this.ethereumAddress), 18)
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
      let initialBalance = 0
      try{
        initialBalance = await cryptoravesToken.balanceOf(this.ethereumAddress, this.ERC1155tokenIdForERC20)
      }catch{}
      let tokenManagerContract = new this.ethers.Contract(
        this.TokenManagementContractAddress, 
        abis['TokenManagement'].abi, 
        this.signer
      )

      let randAmount = Math.round((Math.random() * 10 + Number.EPSILON) * 100) / 100
      console.log('Random Amount: ', randAmount)
      let appr = await token.approve(this.TokenManagementContractAddress, this.ethers.utils.parseEther(randAmount.toString()));
      await appr.wait()
      let tx = await tokenManagerContract.deposit(
        this.ethers.utils.parseEther(randAmount.toString()),
        this.ERC20FullAddress,
        20,
        false
      )

      let val = await tx.wait()
      this.ERC20balance = await token.balanceOf(this.ethereumAddress)

      this.ERC1155tokenIdForERC20 = localStorage.ERC1155tokenIdForERC20 = await tokenManagerContract.getManagedTokenIdByAddress(this.ERC20FullAddress)
      console.log('ERC1155 Token ID: '+this.ERC1155tokenIdForERC20)
      
      let finalBalance = await cryptoravesToken.balanceOf(this.ethereumAddress, this.ERC1155tokenIdForERC20)
 
      console.log(
        "Deposit of Random Amount Successful: ", 
        (Math.round((this.ethers.utils.formatUnits(initialBalance, 18) * 1 + randAmount) * 100) / 100).toString(),
        (Math.round(this.ethers.utils.formatUnits(finalBalance, 18) * 100 ) / 100).toString()
      )
      this.setERC20Emoji()
      this.getBalances()
      this.showLoading = false

    },
    async setERC20Emoji(){
      let tokenManagerContract = new this.ethers.Contract(
        this.TokenManagementContractAddress, 
        abis['TokenManagement'].abi, 
        this.signer
      )
      let id = await tokenManagerContract.getManagedTokenIdByAddress(this.ERC20FullAddress)
      let res = await tokenManagerContract.setEmoji(id,'🔥')
      console.log('Emoji set', res)
    },
    async sendWrappedERC20(){
      let token = new this.ethers.Contract(this.ERC20FullAddress, abis['ERC20Full'].abi, this.signer)
      this.showLoading = true
      let cryptoravesTokenContract = new this.ethers.Contract(
        this.CryptoravesTokenContractAddress, 
        abis['CryptoravesToken'].abi, 
        this.signer
      )
      let tokenManagerContract = new this.ethers.Contract(
        this.TokenManagementContractAddress, 
        abis['TokenManagement'].abi, 
        this.signer
      )
      this.ERC1155tokenIdForERC20 = localStorage.ERC1155tokenIdForERC20 = await tokenManagerContract.getManagedTokenIdByAddress(this.ERC20FullAddress)

      let initialBalance = await cryptoravesTokenContract.balanceOf(this.depositAndSendERC20address, this.ERC1155tokenIdForERC20)
      let tx = await cryptoravesTokenContract.safeTransferFrom(
        this.ethereumAddress,
        this.depositAndSendERC20address,
        this.ERC1155tokenIdForERC20,
        this.ethers.utils.parseEther((this.ERC20WrappedBalance * 0.1).toString()),
        this.ethers.utils.formatBytes32String('')
      )
      let val = await tx.wait()

      let finalBalance = await cryptoravesTokenContract.balanceOf(this.depositAndSendERC20address, this.ERC1155tokenIdForERC20)      
      console.log('Send Amount: ', (this.ERC20WrappedBalance * 0.1).toString())
      console.log(
        "Deposit and send of wrapped erc20 tokens Successful: ", 
        (Math.round(this.ethers.utils.formatUnits(initialBalance, 18) * 100) / 100).toString(), 
        (Math.round(this.ethers.utils.formatUnits(finalBalance, 18) * 100 ) / 100).toString()
      )

      this.showLoading = false
      this.getBalances()

    },
    async launchERC721(){
      this.showLoading = true
      let factory = new this.ethers.ContractFactory(abis['ERC721Full'].abi, abis["ERC721Full"].bytecode, this.signer);
      let contract = await factory.deploy(
        this.ethereumAddress, 
        'TestYToken', 'TSTY'
      )

      console.log("Mint Token 0")
      await contract.mint(this.ethereumAddress, 'https://i.picsum.photos/id/0/200/200.jpg')
      console.log("Mint Token 1")
      await contract.mint(this.ethereumAddress, 'https://i.picsum.photos/id/1/200/200.jpg')
      console.log("Mint Token 2")
      await contract.mint(this.ethereumAddress, 'https://i.picsum.photos/id/2/200/200.jpg')

      this.ERC721balance = await contract.balanceOf(this.ethereumAddress)
      console.log('ERC721 Token Launched With Balance: ', this.ERC721balance)
      this.ERC721FullAddress = localStorage.ERC721FullAddress = contract.address

      this.getBalances()

      this.showLoading = false
    }, 
    async getERC721Balance(){
      let contract = new this.ethers.Contract(this.ERC721FullAddress, abis['ERC721Full'].abi, this.signer)
      this.ERC721balance = await contract.balanceOf(this.ethereumAddress)
    },
    async mintERC721(){
      let contract = new this.ethers.Contract(this.ERC721FullAddress, abis['ERC721Full'].abi, this.signer)
      let amount1 = await contract.totalSupply()
      await contract.mint(this.ethereumAddress, 'https://i.picsum.photos/id/'+(amount1+1)+'/200/200.jpg')
      this.getERC721Balance()
    },
    async depositERC721(){
      this.showLoading = true
      let token = new this.ethers.Contract(this.ERC721FullAddress, abis['ERC721Full'].abi, this.signer)      

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
      this.ERC721WrappedId = localStorage.ERC721WrappedId = await tokenManagerContract.getManagedTokenIdByAddress(this.ERC721FullAddress)

      let initialBalance = await cryptoravesToken.balanceOf(this.ethereumAddress, this.ERC721WrappedId)
      console.log('ERC1155 Wrapped Balance Before Deposit: '+initialBalance)

      let heldTokens = await this.getAllERC721sHeld()
      console.log(heldTokens)
      console.log('Depositing first held token (key 0): ', heldTokens[0])
      let appr = await token.approve(this.TokenManagementContractAddress, heldTokens[0]);

      await appr.wait()
      let tx = await tokenManagerContract.deposit(
        heldTokens[0],
        this.ERC721FullAddress,
        721,
        false
      )
      let val = await tx.wait()
      
      console.log('ERC1155 Token ID: '+this.ERC721WrappedId)
      
      let finalBalance = await cryptoravesToken.balanceOf(this.ethereumAddress, this.ERC721WrappedId)
      console.log('ERC1155 Wrapped Balance After Deposit: '+finalBalance)
      console.log(
        "Deposit of Random Amount Successful: ", 
        initialBalance , finalBalance
      )
      this.setERC721Emoji()
      this.showLoading = false
    },
    async setERC721Emoji(){
      let tokenManagerContract = new this.ethers.Contract(
        this.TokenManagementContractAddress, 
        abis['TokenManagement'].abi, 
        this.signer
      )
      let id = await tokenManagerContract.getManagedTokenIdByAddress(this.ERC721FullAddress)
      console.log(id)
      let res = await tokenManagerContract.setEmoji(id,'✨')
      console.log(res)

    },
    async sendWrappedERC721(){
      let token = new this.ethers.Contract(this.ERC721FullAddress, abis['ERC721Full'].abi, this.signer)
      this.showLoading = true
      let cryptoravesTokenContract = new this.ethers.Contract(
        this.CryptoravesTokenContractAddress, 
        abis['CryptoravesToken'].abi, 
        this.signer
      )
      let tokenManagerContract = new this.ethers.Contract(
        this.TokenManagementContractAddress, 
        abis['TokenManagement'].abi, 
        this.signer
      )
      this.ERC1155tokenIdForERC721 = localStorage.ERC1155tokenIdForERC721 = await tokenManagerContract.getManagedTokenIdByAddress(this.ERC721FullAddress)

      let initialBalance = await cryptoravesTokenContract.balanceOf(this.depositAndSendERC721address, this.ERC1155tokenIdForERC721)

      tokenId

      let tx = await cryptoravesTokenContract.safeTransferFrom(
        this.ethereumAddress,
        this.depositAndSendERC20address,
        this.ERC1155tokenIdForERC721,
        tokenId,
        this.ethers.utils.formatBytes32String('')
      )
      let val = await tx.wait()

      let finalBalance = await cryptoravesTokenContract.balanceOf(this.depositAndSendERC721address, this.ERC1155tokenIdForERC721)      
      console.log('Send ID: ', tokenId)
      console.log(
        "Deposit and send of wrapped erc721 tokens Successful: ", 
        initialBalance, 
        finalBalance,
      )

      this.showLoading = false
      this.getBalances()

    },
    async depositAndSendERC721(tokenId){
      let token = new this.ethers.Contract(this.ERC721FullAddress, abis['ERC721Full'].abi, this.signer)
      
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

      this.ERC1155tokenIdForERC721 = localStorage.ERC1155tokenIdForERC721 = await tokenManagerContract.getManagedTokenIdByAddress(this.ERC721FullAddress)
      console.log(this.depositAndSendERC721address)
      console.log(this.ERC1155tokenIdForERC721.toString())
      let initialBalance = await cryptoravesToken.balanceOf(this.depositAndSendERC721address, this.ERC1155tokenIdForERC721.toString())
      let appr = await token.approve(this.TokenManagementContractAddress, tokenId);

      let tx = await tokenManagerContract.deposit(
        tokenId,
        this.ERC721FullAddress,
        721,
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
        this.depositAndSendERC721address,
        this.ERC1155tokenIdForERC721,
        tokenId,
        this.ethers.utils.formatBytes32String('')
      )
      val = await tx.wait()

      let finalBalance = await cryptoravesToken.balanceOf(this.depositAndSendERC721address, this.ERC1155tokenIdForERC721)
      
      
      console.log(
        "Deposit and send of 1 token Successful: ", 
        (Math.round((this.ethers.utils.formatUnits(initialBalance, 18) * 1 + 1) * 100) / 100).toString(), 
        (Math.round(this.ethers.utils.formatUnits(finalBalance, 18) * 100 ) / 100).toString(),
        'Token ID: TODO: deep check this', tokenId, 
      )

      this.showLoading = false
    },
    async getAllERC721sHeld(){

      let erc721Contract = new this.ethers.Contract(
        this.ERC721FullAddress,
        ['function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId)'], 
        this.signer
      )
      let results = []
      let res
      for(let i=0; i<this.ERC721balance; i++){        
        res = await erc721Contract.tokenOfOwnerByIndex(this.ethereumAddress, i)
        results[i] = res.toString()
      }
      return results
    },
    async getAllWrappedERC721sHeld(){

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
