import Web3 from 'web3'
import { ethers } from 'ethers'

export default {
  components: {},
  data() {
    return {
      ethereumAddress: null
    }
  },
  async mounted() {
    await this.initWeb3()
  },
  methods: {
    async initWeb3() {
      let web3js
      if (window.ethereum) {
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
      let networkId
      try {
        networkId = await web3js.eth.net.getId()
      } catch(e) {
        console.log(e)
      }
      if ([1, 4].includes(networkId)) {
        if (networkId == 4) {
          //mainnet check for live site
          if (
            window.location
              .toString()
              .includes('https://')
          ) {
            alert('Please switch Metamask to Main Ethereum Network')
          }
        }
        if (networkId == 1) {
          //mainnet check for live site
          if (
            !window.location
              .toString()
              .includes('https://') &&
            !this.forceLive
          ) {
            alert('Please switch Metamask to Rinkeby Test Network')
          }
        }
      } else {
        this.showEnableMetaMask = true
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
      }
    }
  }
}