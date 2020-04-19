<template>
  <div class="container">
    <div>
      <h1 class="title">
        ERC20 Contract Factory
      </h1>
      <div>
      	<h2 class="subtitle">
	        Tinker with contract factory
	     </h2>
       <div class="content">
          <div
            v-if="!wallet" 
            class="links">
            <a
              @click="initializeWallet()"
              class="button--green"
            >
              Initialize Wallet
            </a>
          </div>
          <div
            v-else
          ><br>
            <a
              target="_blank" 
              @click="goEtherscan(wallet.address)">
              Wallet Address: {{ this.wallet.address }}
            </a>
          </div>
          <br>
          <form v-if="!launchHash && wallet" name="contact" action="" method="post">
            <label for="name">
              Name:
            </label>
            <input v-model="name" />
            <br>
            <label for="symbol">
              Symbol:
            </label>
            <input v-model="symbol" />
            <br>
            <label for="totalSupply">
              Total Supply:
            </label>
            <input v-model="totalSupply"/>
            <br>
            <label for="decimals" >
              Decimals:
            </label>
            <input v-model="decimals" ></input>
            <br><br>          
          </form>
          <div
            v-if="!launchHash && wallet" 
            class="links">
            <a
              @click="launchToken()"
              class="button--green"
            >
              Launch
            </a>
          </div>
          <div
            v-else
          ><br>
            <a v-if="launchHash"
              target="_blank" 
              @click="goEtherscan(launchHash)">
              New Contract Hash: {{ this.launchHash }}
            </a>
          </div>
          <br>
          <form v-if="launchHash" name="send" action="" method="post">
            <label for="recipientAddress">
              Send to:
            </label>
            <input v-model="recipientAddress" />
            <br>
            <label for="amount">
              Amount:
            </label>
            <input v-model="amount" />
            <br><br>          
          </form>
          <div 
            class="links">
            <a
              @click="sendToken()"
              class="button--green"
            >
              Send {{this.amount}} of {{ this.symbol }} tokens to: {{ this.recipientAddress}}
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

import MetamaskHandler from "./metamaskHandler"

export default {
  extends: MetamaskHandler,
  components: {},
  data() {
    return {
      contractFactoryAddress: '0x471FE61C929c03F534E32af51509DA308D911C3f',
      wallet: null,
      name: 'tokenA',
      symbol: 'TKA',
      totalSupply: '1000000000000000000000000000',
      decimals: 18,
      launchHash: null,
      launchAddress: null,
      recipient: null,
      recipientAddress: null,
      amount: 100
    }
  },
  async mounted() {
    //let token = new ethers.Contract('0x471FE61C929c03F534E32af51509DA308D911C3f', abi, wallet1)
  },
  methods: {
    async initializeWallet(){
      //this.wallet = new this.ethers.Wallet.createRandom()
      this.wallet = new this.ethers.Wallet.fromMnemonic('wrist great knee profit inject clutch perfect purse faith lens vacuum world')
      this.wallet = this.wallet.connect(this.ethereumProvider)

      this.recipient = new this.ethers.Wallet.createRandom()
      this.recipientAddress = this.recipient.address
    },
  	async launchToken(){
  		let abi = [
          'function createEIP20(uint256 _initialAmount, string _name, uint8 _decimals, string _symbol) public returns (address)'
      ]
      

      let token = new this.ethers.Contract(
        this.contractFactoryAddress, 
        abi, 
        this.wallet
      )

      let tx = await token.createEIP20(
        this.totalSupply,
        this.name,
        this.decimals,
        this.symbol 
      )
      let val = await tx.wait()
      
      this.launchHash = JSON.stringify(tx.hash).replace(/['"]+/g, '')
      this.launchAddress = val.events[0].address


  	},
    async sendToken(){

      let abi = [
        'function balanceOf(address who) external view returns (uint256)',
        'function transfer(address to, uint256 value) external returns (bool)'
      ]

      let token = new this.ethers.Contract(this.launchAddress, abi, this.wallet)

      let amount1 = await token.balanceOf(this.wallet.address)
      let amount2 = await token.balanceOf(this.recipient.address)
      console.log('Balance #1: ', this.ethers.utils.formatEther(amount1))
      console.log('Balance #2: ', this.ethers.utils.formatEther(amount2))

      let tx = await token.transfer(this.recipient.address,this.ethers.utils.parseEther(this.amount.toString()))
      await tx.wait()

      amount1 = await token.balanceOf(this.wallet.address)
      amount2 = await token.balanceOf(this.recipient.address)
      console.log('Balance #1: ', this.ethers.utils.formatEther(amount1))
      console.log('Balance #2: ', this.ethers.utils.formatEther(amount2))
    },
    goEtherscan(param){
      if (param.length == 42){
        window.open('https://rinkeby.etherscan.io/address/'+param)
      }else{
        window.open('https://rinkeby.etherscan.io/tx/'+param)
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