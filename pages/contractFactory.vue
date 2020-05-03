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
            v-if="!ethereumAddress" 
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
              @click="goEtherscan(ethereumAddress)">
              Wallet Address: {{ this.ethereumAddress }}
            </a>
          </div>
          <br>
          <form v-if="!launchHash && ethereumAddress" name="contact" action="" method="post">
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
            v-if="!launchHash && ethereumAddress" 
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
            v-if="launchHash"
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
    if (this.$store.state.launchAddress && this.$store.state.launchHash){
      this.launchAddress = this.$store.state.launchAddress
      this.launchHash = this.$store.state.launchHash
    }
    if (this.$store.state.recipient && this.$store.state.recipientAddress){
      this.recipient = this.$store.state.recipient
      this.recipientAddress = this.$store.state.recipientAddress
    }
  },
  methods: {

    async initializeWallet(){
      //this.wallet = new this.ethers.Wallet.createRandom()
      //this.wallet = new this.ethers.Wallet.fromMnemonic('wrist great knee profit inject clutch perfect purse faith lens vacuum world')
      //this.wallet = this.wallet.connect(this.ethereumProvider)

      this.signer = this.ethereumProvider.getSigner(0)
      this.recipient = new this.ethers.Wallet.createRandom()
      this.recipientAddress = this.recipient.address

    },
  	async launchToken(){

      if (this.$store.state.launchAddress && this.$store.state.launchHash){
        this.launchAddress = this.$store.state.launchAddress
        this.launchHash = this.$store.state.launchHash
      }else{

    		let abi = [
            'function createEIP20(uint256 _initialAmount, string _name, uint8 _decimals, string _symbol) public returns (address)'
        ]
        
        let signer = this.ethereumProvider.getSigner(0)

        let token = new this.ethers.Contract(
          this.contractFactoryAddress, 
          abi, 
          signer
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

        this.$store.commit({
          type: 'setLaunchInfo',
          launchAddress: this.launchAddress,
          launchHash: this.launchHash
        })

        this.recipient = new this.ethers.Wallet.createRandom()
        this.recipientAddress = this.recipient.address

        this.$store.commit({
          type: 'setRecipientInfo',
          recipient: this.recipient,
          recipientAddress: this.recipientAddress
        })
      }

  	},
    async sendToken(){

      let abi = [
        'function balanceOf(address who) external view returns (uint256)',
        'function transfer(address to, uint256 value) external returns (bool)'
      ]

      let signer = this.ethereumProvider.getSigner(0)

      let token = new this.ethers.Contract(this.launchAddress, abi, signer)

      let amount1 = await token.balanceOf(this.ethereumAddress)
      let amount2 = await token.balanceOf(this.recipient.address)
      console.log('Balance #1: ', this.ethers.utils.formatEther(amount1))
      console.log('Balance #2: ', this.ethers.utils.formatEther(amount2))

      let tx = await token.transfer(this.recipient.address,this.ethers.utils.parseEther(this.amount.toString()))
      await tx.wait()

      amount1 = await token.balanceOf(this.ethereumAddress)
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
    },
    async launchFactory(){
      let bytecode = '60806040523480156200001157600080fd5b5060405162000f8b38038062000f8b833981810160405260808110156200003757600080fd5b8101908080519060200190929190805160405193929190846401000000008211156200006257600080fd5b838201915060208201858111156200007957600080fd5b82518660018202830111640100000000821117156200009757600080fd5b8083526020830192505050908051906020019080838360005b83811015620000cd578082015181840152602081019050620000b0565b50505050905090810190601f168015620000fb5780820380516001836020036101000a031916815260200191505b5060405260200180519060200190929190805160405193929190846401000000008211156200012957600080fd5b838201915060208201858111156200014057600080fd5b82518660018202830111640100000000821117156200015e57600080fd5b8083526020830192505050908051906020019080838360005b838110156200019457808201518184015260208101905062000177565b50505050905090810190601f168015620001c25780820380516001836020036101000a031916815260200191505b5060405250505083600160003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020819055508360008190555082600390805190602001906200022c9291906200026b565b5081600460006101000a81548160ff021916908360ff1602179055508060059080519060200190620002609291906200026b565b50505050506200031a565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f10620002ae57805160ff1916838001178555620002df565b82800160010185558215620002df579182015b82811115620002de578251825591602001919060010190620002c1565b5b509050620002ee9190620002f2565b5090565b6200031791905b8082111562000313576000816000905550600101620002f9565b5090565b90565b610c61806200032a6000396000f3fe608060405234801561001057600080fd5b50600436106100a95760003560e01c8063313ce56711610071578063313ce567146102935780635c658165146102b757806370a082311461032f57806395d89b4114610387578063a9059cbb1461040a578063dd62ed3e14610470576100a9565b806306fdde03146100ae578063095ea7b31461013157806318160ddd1461019757806323b872dd146101b557806327e235e31461023b575b600080fd5b6100b66104e8565b6040518080602001828103825283818151815260200191508051906020019080838360005b838110156100f65780820151818401526020810190506100db565b50505050905090810190601f1680156101235780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b61017d6004803603604081101561014757600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff16906020019092919080359060200190929190505050610586565b604051808215151515815260200191505060405180910390f35b61019f610678565b6040518082815260200191505060405180910390f35b610221600480360360608110156101cb57600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190803573ffffffffffffffffffffffffffffffffffffffff1690602001909291908035906020019092919050505061067e565b604051808215151515815260200191505060405180910390f35b61027d6004803603602081101561025157600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190505050610916565b6040518082815260200191505060405180910390f35b61029b61092e565b604051808260ff1660ff16815260200191505060405180910390f35b610319600480360360408110156102cd57600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190803573ffffffffffffffffffffffffffffffffffffffff169060200190929190505050610941565b6040518082815260200191505060405180910390f35b6103716004803603602081101561034557600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190505050610966565b6040518082815260200191505060405180910390f35b61038f6109af565b6040518080602001828103825283818151815260200191508051906020019080838360005b838110156103cf5780820151818401526020810190506103b4565b50505050905090810190601f1680156103fc5780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b6104566004803603604081101561042057600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff16906020019092919080359060200190929190505050610a4d565b604051808215151515815260200191505060405180910390f35b6104d26004803603604081101561048657600080fd5b81019080803573ffffffffffffffffffffffffffffffffffffffff169060200190929190803573ffffffffffffffffffffffffffffffffffffffff169060200190929190505050610ba4565b6040518082815260200191505060405180910390f35b60038054600181600116156101000203166002900480601f01602080910402602001604051908101604052809291908181526020018280546001816001161561010002031660029004801561057e5780601f106105535761010080835404028352916020019161057e565b820191906000526020600020905b81548152906001019060200180831161056157829003601f168201915b505050505081565b600081600260003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020819055508273ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff167f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925846040518082815260200191505060405180910390a36001905092915050565b60005481565b600080600260008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002054905082600160008773ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020541015801561074f5750828110155b61075857600080fd5b82600160008673ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000206000828254019250508190555082600160008773ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020600082825403925050819055507fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff8110156108a55782600260008773ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020600082825403925050819055505b8373ffffffffffffffffffffffffffffffffffffffff168573ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef856040518082815260200191505060405180910390a360019150509392505050565b60016020528060005260406000206000915090505481565b600460009054906101000a900460ff1681565b6002602052816000526040600020602052806000526040600020600091509150505481565b6000600160008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020549050919050565b60058054600181600116156101000203166002900480601f016020809104026020016040519081016040528092919081815260200182805460018160011615610100020316600290048015610a455780601f10610a1a57610100808354040283529160200191610a45565b820191906000526020600020905b815481529060010190602001808311610a2857829003601f168201915b505050505081565b600081600160003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020541015610a9b57600080fd5b81600160003373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000206000828254039250508190555081600160008573ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020600082825401925050819055508273ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef846040518082815260200191505060405180910390a36001905092915050565b6000600260008473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008373ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000205490509291505056fea26469706673582212207ce97128bec7ac012652ba3d893c0c0546c8cbccef4f70e80622d4cb27bd718064736f6c63430006060033'

      let abi = [
        {
          "inputs": [
            {
              "internalType": "uint256",
              "name": "_initialAmount",
              "type": "uint256"
            },
            {
              "internalType": "string",
              "name": "_tokenName",
              "type": "string"
            },
            {
              "internalType": "uint8",
              "name": "_decimalUnits",
              "type": "uint8"
            },
            {
              "internalType": "string",
              "name": "_tokenSymbol",
              "type": "string"
            }
          ],
          "stateMutability": "nonpayable",
          "type": "constructor"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": true,
              "internalType": "address",
              "name": "_owner",
              "type": "address"
            },
            {
              "indexed": true,
              "internalType": "address",
              "name": "_spender",
              "type": "address"
            },
            {
              "indexed": false,
              "internalType": "uint256",
              "name": "_value",
              "type": "uint256"
            }
          ],
          "name": "Approval",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": true,
              "internalType": "address",
              "name": "_from",
              "type": "address"
            },
            {
              "indexed": true,
              "internalType": "address",
              "name": "_to",
              "type": "address"
            },
            {
              "indexed": false,
              "internalType": "uint256",
              "name": "_value",
              "type": "uint256"
            }
          ],
          "name": "Transfer",
          "type": "event"
        },
        {
          "inputs": [
            {
              "internalType": "address",
              "name": "_owner",
              "type": "address"
            },
            {
              "internalType": "address",
              "name": "_spender",
              "type": "address"
            }
          ],
          "name": "allowance",
          "outputs": [
            {
              "internalType": "uint256",
              "name": "remaining",
              "type": "uint256"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "address",
              "name": "",
              "type": "address"
            },
            {
              "internalType": "address",
              "name": "",
              "type": "address"
            }
          ],
          "name": "allowed",
          "outputs": [
            {
              "internalType": "uint256",
              "name": "",
              "type": "uint256"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "address",
              "name": "_spender",
              "type": "address"
            },
            {
              "internalType": "uint256",
              "name": "_value",
              "type": "uint256"
            }
          ],
          "name": "approve",
          "outputs": [
            {
              "internalType": "bool",
              "name": "success",
              "type": "bool"
            }
          ],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "address",
              "name": "_owner",
              "type": "address"
            }
          ],
          "name": "balanceOf",
          "outputs": [
            {
              "internalType": "uint256",
              "name": "balance",
              "type": "uint256"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "address",
              "name": "",
              "type": "address"
            }
          ],
          "name": "balances",
          "outputs": [
            {
              "internalType": "uint256",
              "name": "",
              "type": "uint256"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "decimals",
          "outputs": [
            {
              "internalType": "uint8",
              "name": "",
              "type": "uint8"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "name",
          "outputs": [
            {
              "internalType": "string",
              "name": "",
              "type": "string"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "symbol",
          "outputs": [
            {
              "internalType": "string",
              "name": "",
              "type": "string"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "totalSupply",
          "outputs": [
            {
              "internalType": "uint256",
              "name": "",
              "type": "uint256"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "address",
              "name": "_to",
              "type": "address"
            },
            {
              "internalType": "uint256",
              "name": "_value",
              "type": "uint256"
            }
          ],
          "name": "transfer",
          "outputs": [
            {
              "internalType": "bool",
              "name": "success",
              "type": "bool"
            }
          ],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "address",
              "name": "_from",
              "type": "address"
            },
            {
              "internalType": "address",
              "name": "_to",
              "type": "address"
            },
            {
              "internalType": "uint256",
              "name": "_value",
              "type": "uint256"
            }
          ],
          "name": "transferFrom",
          "outputs": [
            {
              "internalType": "bool",
              "name": "success",
              "type": "bool"
            }
          ],
          "stateMutability": "nonpayable",
          "type": "function"
        }
      ]

      (async function() {
        // Create an instance of a Contract Factory
        let factory = new ethers.ContractFactory(abi, bytecode, wallet);

        let contract = await factory.deploy();
        console.log(contract.address);
        console.log(contract.deployTransaction.hash);
        
        // The contract is NOT deployed yet; we must wait until it is mined
        await contract.deployed()
      })();
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