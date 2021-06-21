<template>
  <div
    class="container"
  >
    <div v-if='loadNetworkData()'></div>
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
        Oracle Features Testing Page
      </h1>
      <h2 class="subtitle">
        For Testing And Developing Token Management System Through The Oracle
      </h2>
      <div>
        <input
          v-model="searchFoprNFTTickerAndErc721Index"
          v-on:keyup="searchNFTbyTicker"
          placeholder="TSTY 0">
        <p>Ticker Base ID: {{ searchForNFTIdResult }}</p>
        <p>Ticker Full ID: {{ searchForNFTIdResultFullID }}</p>
      </div>
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
            v-if="ERC20FullAddress"
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
          v-if="ERC20FullAddress"
          class="links">
          <a

            @click="offlineSignERC20()"
            class="button--green"
          >
            Sign Meta Transaction ERC20
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
          <a  v-if="ERC721WrappedBaseId > 0"
              target="_blank">
              Your ERC721 Wrapped Base ID: {{ this.ERC721WrappedBaseId }}<br>

          </a>
          <a  v-if="ERC721balance"
              target="_blank"
              @click="goEtherscan(ERC721FullAddress)">
              Your ERC721 Balance: {{ this.ERC721balance }}<br>
          </a>
          <a  v-if="ERC721balance && ERC721WrappedBaseId > 0"
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
              Mint An ERC721 To Your Wallet
          </a>
          <br>
          <a

            @click="depositERC721()"
            class="button--green"
          >
            Deposit Test ERC721 Tokens
          </a>
          <br><a
            v-if="ERC721FullAddress"
            @click="launchERC721()"
            class="button--green"
          >
            Launch A New ERC721
          </a><br><br>
        </div>
        <div
          v-if="ERC721FullAddress && ERC721WrappedBaseId"
          class="links">
          <input v-model="depositAndSendERC721address">
          <br><br>
          <a

            @click="sendWrappedERC721()"
            class="button--green"
          >
            Send A Wrapped ERC721 To Above Address
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
          <div
            class="links">
            <br>
            <br>
            <a
              @click="pruneToken()"
              class="button--green"
            >
              Prune Token
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
      searchFoprNFTTickerAndErc721Index: 'TSTY 0',
      searchForNFTIdResult: null,
      searchForNFTIdResultFullID: null,
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
      ERC721WrappedBaseId: 0,
      showLoading: false,
      depositAndSendERC20address: '0xabc...',
      depositAndSendERC721address: '0x123...'
    }
  },
  created() {
    this.checkAbis()

  },
  async mounted() {

    await this.initWeb3()
    await this.getBalances()


  },
  methods: {
    async searchNFTbyTicker(e){
      if (e.keyCode === 13) {
        try{
          let tokenManagerContract = this.loadTokenManagementContract()
          let args = this.searchFoprNFTTickerAndErc721Index.toUpperCase().split(' ')
          console.log(await tokenManagerContract.cryptoravesIdByAddress(this.ERC721FullAddress))
          this.searchForNFTIdResult = await tokenManagerContract.symbolAndEmojiLookupTable(args[0])
          this.searchForNFTIdResult = this.searchForNFTIdResult.toHexString()
          this.searchForNFTIdResultFullID = await tokenManagerContract.getCryptoravesNFTIDbyTickerAndIndex(args[0], args[1])
          this.searchForNFTIdResultFullID = this.searchForNFTIdResultFullID.toHexString()

          console.log('Base ID: ', await tokenManagerContract.getNonFungibleBaseType(this.searchForNFTIdResultFullID))
          console.log('NFT Index: ', await tokenManagerContract.getNonFungibleIndex(this.searchForNFTIdResultFullID))
          console.log('ERC721 IdByAddress: ', await tokenManagerContract.cryptoravesIdByAddress(this.ERC721FullAddress))
          console.log('Full Cryptoraves Token Object',await tokenManagerContract.managedTokenByFullBytesId(this.searchForNFTIdResultFullID))
        }catch(e){
          console.log(e)
        }
      }
    },
    async offlineSignERC20(){
      if(this.ERC20FullAddress){
        let tokenValue = this.ethers.utils.parseEther((this.ERC20WrappedBalance * 0.1).toString())
        //let tokenValue = this.ethers.utils.parseEther((0.1).toString())
        let fnSignature = web3.utils.keccak256("transferFrom(address,address,uint256)").substr(0,10)

        let fnParams = web3.eth.abi.encodeParameters(
          ["address","address","uint256"],
          [this.ethereumAddress,'0x972ddf1f33e23e0d56c1c4166ff19b2dd2d3aa69',tokenValue]
        )
        let calldata = fnSignature + fnParams.substr(2)

        console.log('Calldata: ',calldata)

        let rawData = web3.eth.abi.encodeParameters(
          ['address','bytes'],
          [this.ERC20FullAddress,calldata]
        );
        // hash the data.
        let hash = web3.utils.soliditySha3(rawData);

        // sign the hash.
        let signature = await web3.eth.sign(hash, this.ethereumAddress);

        console.log('Signature: ',signature)
      }
    },
    loadNetworkData(){
      if(this.networkType){
        this.importContractStructureForThisNetwork(false)
        return true
      }
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
        this.ERC20FullAddress = localStorage.ERC20FullAddress = savedNetwork[this.networkType]["ERC20FullAddress"]
        this.ERC721FullAddress = localStorage.ERC721FullAddress = savedNetwork[this.networkType]["ERC721FullAddress"]

        this.AdminToolsLibraryAddress = localStorage.AdminToolsLibraryAddress = savedNetwork[this.networkType]["AdminToolsLibraryAddress"]

      }else{
        if(alertsBool){
          alert('Network Name doesn\'t match. Cannot Save Info.', this.networkType, savedNetwork[this.networkType]["networkType"])
        }
      }
    },
    exportContractStructureForThisNetwork(alertsBool){
      if(this.networkType){
        let networkInfo = {}
        if(localStorage.networkInfo){
          networkInfo = JSON.parse(localStorage.networkInfo)
        }else{
          networkInfo[this.networkType] = {}
        }
        //if localsotrage.networkName is set then prompt for overwrite confirmation
        let savedNetwork = {}
        if (this.ERC20FullAddress){
          networkInfo[this.networkType]["ERC20FullAddress"] = this.ERC20FullAddress
        }
        if (this.ERC721FullAddress){
          networkInfo[this.networkType]["ERC721FullAddress"] = this.ERC721FullAddress
        }

        localStorage.networkInfo = JSON.stringify(networkInfo)

        this.copyToClipboard(localStorage.networkInfo)
        console.log('Network Info Saved for '+this.networkType+ ' and copied to clipboard')


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
    checkAbis(){
      this.contractNames.forEach(function(element) {
        if(typeof abis[element] === 'undefined') {
          throw new Error('No ABI found for '+element)
        }
      })
      return true
    },
    async getBalances(){

      try {
        await this.getERC20Balance()
      }catch(e){
        console.log(e,'Error with init getERC20Balance')
      }
      try {
        await this.getERC721Balance()
      }catch(e){
        console.log(e,'Error with init getERC721Balance')
      }

      //pause for matic's RPC limit
      if (this.networkType == 'Matic Testnet'){
        await this.sleep(1000)
      }

      try {
        await this.getAllERC721sHeld()
      }catch(e){
        console.log(e,'Error with init getAllERC721sHeld')
      }
      try {
        await this.getWrappedBalances()
      }catch(e){
        console.log(e,'Error with init getWrappedBalances')
      }
      try {
        await this.getEmojis()
      }catch(e){
        console.log(e,'Error with init getEmojis')
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
      let tokenManagerContract = this.loadTokenManagementContract()
      let cryptoravesToken = this.loadCryptoravesTokenContract()
      let ERC1155tokenIdForERC20 = await tokenManagerContract.cryptoravesIdByAddress(this.ERC20FullAddress)
      this.ERC20WrappedBalance = this.ethers.utils.formatUnits(
        await cryptoravesToken.balanceOf(this.ethereumAddress, ERC1155tokenIdForERC20),
        18
      )
      this.ERC20WrappedId = ERC1155tokenIdForERC20

      this.getBalances()
      this.exportContractStructureForThisNetwork(false)
      this.showLoading = false
    },
    async getWrappedBalances(){

      let tokenManagerContract = this.loadTokenManagementContract()
      let cryptoravesToken = this.loadCryptoravesTokenContract()
      let ERC1155tokenIdForERC20 = await tokenManagerContract.cryptoravesIdByAddress(this.ERC20FullAddress)
      this.ERC20WrappedBalance = this.ethers.utils.formatUnits(
        await cryptoravesToken.balanceOf(this.ethereumAddress, ERC1155tokenIdForERC20),
        18
      )
      this.ERC20WrappedId = ERC1155tokenIdForERC20

      let ERC1155tokenIdForERC721 = await tokenManagerContract.cryptoravesIdByAddress(this.ERC721FullAddress)
      let held1155s = await this.getAll1155TokensHeld()
      let upperLimit = await tokenManagerContract.getNextBaseId(ERC1155tokenIdForERC721)
      let ERC721WrappedBalance = 0
      let ethAddr = this.ethereumAddress

      //pause for matic's RPC limit
      if (this.networkType == 'Matic Testnet'){
        await this.sleep(500)
      }
      console.log('upper limit: ', upperLimit)
      held1155s.forEach( async function(element) {
        console.log(element)
        if(element.lt(upperLimit) && element.gte(ERC1155tokenIdForERC721)){

          new Promise(resolve => setTimeout(resolve, 250))
          ERC721WrappedBalance++
          console.log(element.toString(), await cryptoravesToken.balanceOf(ethAddr, element))
        }
      })
      this.ERC721WrappedBalance = ERC721WrappedBalance
      this.ERC721WrappedBaseId = ERC1155tokenIdForERC721

    },
    async getEmojis(){
      let tokenManagerContract = this.loadTokenManagementContract()
      this.ERC20Emoji = await tokenManagerContract.getEmoji(this.ERC20WrappedId)
      this.ERC721Emoji = await tokenManagerContract.getEmoji(this.ERC721WrappedBaseId)
      console.log('get address by ticker:',await tokenManagerContract.getAddressBySymbol(this.ERC721Emoji))
    },
    async getERC20Balance(){
          console.log(this.ERC20FullAddress, abis['ERC20Full'].abi)
      let token = new this.ethers.Contract(this.ERC20FullAddress, abis['ERC20Full'].abi, this.signer)
      this.ERC20balance = this.ethers.utils.formatUnits(await token.balanceOf(this.ethereumAddress), 18)
    },
    async depositERC20(){

      let token = new this.ethers.Contract(this.ERC20FullAddress, abis['ERC20Full'].abi, this.signer)
      let amount1 = await token.balanceOf(this.ethereumAddress)

      this.showLoading = true

      let cryptoravesToken = this.loadCryptoravesTokenContract()
      let initialBalance = 0
      try{
        initialBalance = await cryptoravesToken.balanceOf(this.ethereumAddress, this.ERC1155tokenIdForERC20)
      }catch{}
      let tokenManagerContract = this.loadTokenManagementContract()

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

      //pause for matic's RPC limit
      if (this.networkType == 'Matic Testnet'){
        await this.sleep(1000)
      }

      this.ERC1155tokenIdForERC20 = localStorage.ERC1155tokenIdForERC20 = await tokenManagerContract.cryptoravesIdByAddress(this.ERC20FullAddress)
      console.log(this.ERC1155tokenIdForERC20)
      console.log('ERC1155 Token ID: '+this.ERC1155tokenIdForERC20)

      let finalBalance = await cryptoravesToken.balanceOf(this.ethereumAddress, this.ERC1155tokenIdForERC20)



      console.log(
        "Deposit of Random Amount Successful: ",
        (Math.round((this.ethers.utils.formatUnits(initialBalance, 18) * 1 + randAmount) * 100) / 100).toString(),
        (Math.round(this.ethers.utils.formatUnits(finalBalance, 18) * 100 ) / 100).toString()
      )
      this.setERC20Emoji()

      //pause for matic's RPC limit
      if (this.networkType == 'Matic Testnet'){
        await this.sleep(1000)
      }

      this.getBalances()
      this.showLoading = false

    },
    async setERC20Emoji(){
      let tokenManagerContract = this.loadTokenManagementContract()
      let id = await tokenManagerContract.cryptoravesIdByAddress(this.ERC20FullAddress)
      let res = await tokenManagerContract.setEmoji(id,'🔥')
      console.log('Emoji set', res)
    },
    async sendWrappedERC20(){
      let token = new this.ethers.Contract(this.ERC20FullAddress, abis['ERC20Full'].abi, this.signer)
      this.showLoading = true
      let cryptoravesTokenContract = this.loadCryptoravesTokenContract()
      let tokenManagerContract = this.loadTokenManagementContract()
      this.ERC1155tokenIdForERC20 = localStorage.ERC1155tokenIdForERC20 = await tokenManagerContract.cryptoravesIdByAddress(this.ERC20FullAddress)

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
        'TestYToken', 'TSTY',
        'https://i.picsum.photos/id/0/200/200.jpg'
      )

      console.log("Mint Token 0")
      await contract.mint(this.ethereumAddress)
      console.log("Mint Token 1")
      await contract.mint(this.ethereumAddress)
      console.log("Mint Token 2")
      await contract.mint(this.ethereumAddress)

      this.ERC721balance = await contract.balanceOf(this.ethereumAddress)
      console.log('ERC721 Token Launched With Balance: ', this.ERC721balance)
      this.ERC721FullAddress = localStorage.ERC721FullAddress = contract.address

      this.getBalances()
      this.exportContractStructureForThisNetwork(false)
      this.showLoading = false
    },
    async getERC721Balance(){
      let contract = new this.ethers.Contract(this.ERC721FullAddress, abis['ERC721Full'].abi, this.signer)
      this.ERC721balance = await contract.balanceOf(this.ethereumAddress)
    },
    async mintERC721(){
      let contract = new this.ethers.Contract(this.ERC721FullAddress, abis['ERC721Full'].abi, this.signer)
      let amount1 = await contract.totalSupply()
      await contract.mint(this.ethereumAddress)//, 'https://i.picsum.photos/id/'+(amount1+1)+'/200/200.jpg')
      this.getERC721Balance()
    },
    async depositERC721(){
      this.showLoading = true
      let token = new this.ethers.Contract(this.ERC721FullAddress, abis['ERC721Full'].abi, this.signer)

      let cryptoravesToken = this.loadCryptoravesTokenContract()
      let tokenManagerContract = this.loadTokenManagementContract()
      this.ERC721WrappedBaseId = localStorage.ERC721WrappedBaseId = await tokenManagerContract.cryptoravesIdByAddress(this.ERC721FullAddress)

      let bigNumberBaseId = this.ERC721WrappedBaseId

      let initialBalance = this.ERC721WrappedBalance
      console.log('ERC1155 Wrapped Balance Before Deposit: '+initialBalance)

      let heldTokens = await this.getAllERC721sHeld()

      console.log('Depositing first held token (key 0): ', heldTokens[0])
      let appr = await token.approve(this.TokenManagementContractAddress, heldTokens[0]);

      console.log(await tokenManagerContract.cryptoravesIdByAddress(this.ERC721FullAddress))

      let tx = await tokenManagerContract.deposit(
        heldTokens[0],
        this.ERC721FullAddress,
        721,
        false
      )

      let val = await tx.wait()

      this.getWrappedBalances()
      let finalBalance = this.ERC721WrappedBalance

      console.log('ERC1155 Wrapped Balance After Deposit: '+finalBalance)
      console.log(
        "Deposit of 1 NFT Successful: Ticker: TSTY OrgId: ",heldTokens[0]
      )

      //pause for matic's RPC limit
      if (this.networkType == 'Matic Testnet'){
        await this.sleep(1000)
      }

      this.setERC721Emoji()
      this.getBalances()
      this.showLoading = false
    },
    async setERC721Emoji(){
      let tokenManagerContract = this.loadTokenManagementContract()
      let id = await tokenManagerContract.cryptoravesIdByAddress(this.ERC721FullAddress)
      let res = await tokenManagerContract.setEmoji(id,'✨')
    },
    async sendWrappedERC721(){
      let token = new this.ethers.Contract(this.ERC721FullAddress, abis['ERC721Full'].abi, this.signer)
      this.showLoading = true
      let cryptoravesTokenContract = this.loadCryptoravesTokenContract()
      let tokenManagerContract = this.loadTokenManagementContract()
      let BaseTokenId = localStorage.BaseTokenId = await tokenManagerContract.cryptoravesIdByAddress(this.ERC721FullAddress)

      let initialBalance = this.ERC721WrappedBalance
      let held1155s = await this.getAll1155TokensHeld()
      let upperLimit = await tokenManagerContract.getNextBaseId(BaseTokenId)
      let ERC721WrappedId = 0
      held1155s.forEach( function(element) {
        if(element.lt(upperLimit) && element.gte(BaseTokenId)){
          ERC721WrappedId=element
        }
      })
      console.log("sending wrapped id:",ERC721WrappedId)
      let tx = await cryptoravesTokenContract.safeTransferFrom(
        this.ethereumAddress,
        this.depositAndSendERC721address,
        ERC721WrappedId,
        1,
        this.ethers.utils.formatBytes32String('')
      )
      let val = await tx.wait()
      this.getBalances()
      let finalBalance = this.ERC721WrappedBalance
      console.log(
        "Transfer of wrapped TSTY tokens Successful. OrgID: ",ERC721WrappedId.sub(BaseTokenId).toString()
      )

      this.showLoading = false

    },
    async depositAndSendERC721(tokenId){
      let token = new this.ethers.Contract(this.ERC721FullAddress, abis['ERC721Full'].abi, this.signer)

      this.showLoading = true

      let cryptoravesToken = this.loadCryptoravesTokenContract()

      let tokenManagerContract = this.loadTokenManagementContract()

      this.ERC1155tokenIdForERC721 = localStorage.ERC1155tokenIdForERC721 = await tokenManagerContract.cryptoravesIdByAddress(this.ERC721FullAddress)
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
      let cryptoravesTokenContract = this.loadCryptoravesTokenContract()

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
    async getAll1155TokensHeld(){
      let cryptoravesTokenContract = this.loadCryptoravesTokenContract()
      return await cryptoravesTokenContract.getHeldTokenIds(this.ethereumAddress)
    },
    loadTokenManagementContract(){
      return new this.ethers.Contract(
        this.TokenManagementContractAddress,
        abis['TokenManagement'].abi,
        this.signer
      )
    },
    loadCryptoravesTokenContract(){
      return new this.ethers.Contract(
        this.CryptoravesTokenContractAddress,
        abis['CryptoravesToken'].abi,
        this.signer
      )
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
    },
    sleep(ms) {
      return new Promise(resolve => setTimeout(resolve, ms));
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
