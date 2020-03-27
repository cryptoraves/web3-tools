<template>
  <div class="container">
    <div>
      <h1 class="title">
        Web3 Tools
      </h1>
      <h2 class="subtitle">
        Fundamental tools for interacting in web3
      </h2>
      <div class="links">
        <a
          @click="go3Box(ethereumAddress)"
          target="_blank"
          class="button--green"
        >
          3Box Tools
        </a>
        <a
          href="https://github.com/nuxt/nuxt.js"
          target="_blank"
          class="button--grey"
        >
          GitHub
        </a>
      </div>
    </div>
  </div>
</template>

<script>
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
    this.ready = true
  },
  methods: {
    go3Box (ethereumAddress){
      this.$router.push({ name: '3box', query: { ethereumAddress: ethereumAddress } })
    },
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
        this.ethereumProvider = new ethers.providers.Web3Provider(
          web3js.currentProvider
        )
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
</style>
