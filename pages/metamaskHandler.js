import Web3 from 'web3'
import { ethers } from 'ethers'

export default {
  components: {},
  data() {
    return {
      ethereumAddress: null,
      networkType: null,
      networkId: null,
      blockExplorerUrl: null,
      ethBlockExplorerUrl: null,
      ethereumProvider: null,
      signer: null,
      web3js: null
    }
  },
  methods: {
    async initWeb3() {
      let web3js
      if (window.ethereum) {
        ethereum.autoRefreshOnNetworkChange = false
        window.web3 = new Web3(ethereum)
        web3js = new Web3(ethereum)
        await ethereum.enable()
      } else if (window.web3) {
        window.web3 = new Web3(window.web3.currentProvider)
        web3js = new Web3(window.web3.currentProvider)
      } else {
        // throw new Error('Please enable Metamask and refresh.')
        this.showEnableMetaMask = true
        return false
      }
      try {
        this.networkId = await web3js.eth.net.getId()
      } catch(e) {
        console.log(e)
      }
      if (this.networkId==344435){
        this.networkType = 'SKALE Bob Testnet'
        this.blockExplorerUrl = 'https://explorer.skale.network/'
        this.ethBlockExplorerUrl = 'https://rinkeby.etherscan.io/'
      } else if (this.networkId==344435){
        this.networkType = 'SKALE Testnet'
        this.blockExplorerUrl = 'https://explorer.skale.network/'
        this.ethBlockExplorerUrl = 'https://rinkeby.etherscan.io/'
      } else if (this.networkId==80001){
        this.networkType = 'Matic Testnet'
        this.blockExplorerUrl = 'https://explorer.testnet2.matic.network/'
        this.ethBlockExplorerUrl = 'https://ropsten.etherscan.io/'
      } else {
        this.networkType = await web3.eth.net.getNetworkType()
        if(this.networkType == 'main'){
          this.blockExplorerUrl = 'https://etherscan.io/'
        }
        if(this.networkType == 'rinkeby'){
          this.blockExplorerUrl = 'https://rinkeby.etherscan.io/'
        }
      }

      if (web3js) {
        this.web3js = web3js
        this.ethers = ethers
        this.ethereumProvider = new ethers.providers.Web3Provider(
          web3js.currentProvider
        )
        this.signer = this.ethereumProvider.getSigner(0)
        this.ethereumAddress = (await this.ethereumProvider.listAccounts())[0]
        window.ethereum.on('accountsChanged', function() {
          const sleep = milliseconds => {
            return new Promise(resolve => setTimeout(resolve, milliseconds))
          }
          sleep(1000)
          location.reload()
        })
        window.ethereum.on('chainChanged', chainId => {
          location.reload()
        })
      }
    }
  }
}
