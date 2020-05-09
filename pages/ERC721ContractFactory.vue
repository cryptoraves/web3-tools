<template>
  <div class="container">
    <div>
      <h1 class="title">
        ERC721 Contract
      </h1>
      <div>
      	<h2 class="subtitle">
	        Tinker with NFT contract
	     </h2>
       <div class="content">
          <div>
            <br>
            <a
              target="_blank" 
              @click="goEtherscan(ethereumAddress)">
              Wallet Address: {{ this.ethereumAddress }}
            </a>
          </div>
          <br>
          <form v-if="ethereumAddress && !launchHash" name="contact" action="" method="post">
            <label for="name">
              Name:
            </label>
            <input v-model="name" disabled/>
            <br>
            <label for="symbol">
              Symbol:
            </label>
            <input v-model="symbol" disabled/>
            <br><br>          
          </form>
          <div
            v-if="ethereumAddress && !launchHash" 
            class="links">
            <a
              @click="launchToken()"
              class="button--green"
            >
              Launch Token
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
            <br>
            <a v-if="launchAddress"
              target="_blank" 
              @click="goEtherscan(launchAddress)">
              New Contract Address: {{ this.launchAddress }}
            </a>
            <div 
              v-if="launchAddress"
              class="links">
              <a
                @click="checkBalance()"
                class="button--green"
                isable
              >
                Check NFT Balance
              </a>
            </div>
          </div>
          <br>
          <div
            v-if="launchHash && !showLoading" 
            class="links">
            <a
              @click="mintToken()"
              class="button--green"
            >
              Mint A Token
            </a>
            
          </div>
          <br>
          <form v-if="launchHash && !showLoading && tokenBalance" name="send" action="" method="post">
            <label for="recipientAddress">
              Send to:
            </label>
            <input v-model="recipientAddress" />
            <br>
            <label for="tokenID">
              Token ID:
            </label>
            <input v-model="tokenID" />
            <br>   
            <div 
              class="links">
              <a
                @click="sendToken()"
                class="button--green"
                isable
              >
                Send {{ this.symbol }} token id {{this.tokenID}} to: {{ this.recipientAddress}}
              </a>
            </div>      
          </form>
          <br><br>
          <div
            v-if="showLoading"
          >
            <img 
              src="../assets/gif/loading.gif" 
              alt >
          </div>
          <div 
            v-if="launchAddress"
            class="links">
            <a
              @click="resetLocalStorage()"
              class="button--green"
            >
              Start From Scratch
            </a>
          </div>
          <div 
            v-if="launchAddress"
            class="links">
            <a
              @click="createRecipient()"
              class="button--green"
            >
             Create Recipient
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
  async mounted() {
    //localStorage.contractFactoryAddress = '0x471FE61C929c03F534E32af51509DA308D911C3f' original factory address
    if (localStorage.ERC721launchAddress) this.launchAddress = localStorage.ERC721launchAddress
    if (localStorage.ERC721launchHash) this.launchHash = localStorage.ERC721launchHash
    if (localStorage.recipientAddress) this.recipientAddress = localStorage.recipientAddress
    if (localStorage.ERC721TokenId) this.tokenID = localStorage.ERC721TokenId
  },
  methods: {
    async initializeWallet(){
      //this.wallet = new this.ethers.Wallet.createRandom()
      //this.wallet = new this.ethers.Wallet.fromMnemonic('wrist great knee profit inject clutch perfect purse faith lens vacuum world')
      //this.wallet = this.wallet.connect(this.ethereumProvider)
    },
  	async launchToken(){

      let factory = new this.ethers.ContractFactory(this.abi, this.bytecode, this.signer);

      let contract = await factory.deploy();

      this.showLoading = true
      await contract.deployed()
      this.showLoading = false

      this.launchHash = localStorage.ERC721launchHash = contract.deployTransaction.hash
      this.launchAddress = localStorage.ERC721launchAddress = contract.address

      await this.createRecipient()

      this.tokenBalance = await this.checkBalance()
  	},
    async createRecipient(){
      let recipient = new this.ethers.Wallet.createRandom()
      this.recipientAddress = localStorage.ERC721recipientAddress = recipient.address
    },
    async checkBalance(){
      if (!this.recipientAddress){
        await this.createRecipient()
      }
      if (localStorage.ERC721launchAddress){
        let token = new this.ethers.Contract(this.launchAddress, this.abi, this.signer)
        let amount1 = await token.balanceOf(this.ethereumAddress)
        amount1 = amount1.toNumber()
        alert("Your NFT Token Balance is: "+amount1)
        this.tokenID = localStorage.ERC721TokenId = this.tokenBalance = amount1
        return amount1
      }
      return 0
    },
    async mintToken(){

      let token = new this.ethers.Contract(this.launchAddress, this.abi, this.signer)
      let uri = 'https://i.picsum.photos/id/'+this.tokenID+'/200/200.jpg'
      let tx = await token.mint(this.ethereumAddress, uri)

      this.showLoading = true
      let val = await tx.wait()
      this.showLoading = false
      
      this.tokenID = localStorage.ERC721TokenId = this.tokenBalance = await this.checkBalance()

    },
    async sendToken(){

      let abi = [
        'function balanceOf(address owner) public view returns (uint256)',
        'function safeTransferFrom(address from, address to, uint256 tokenId) public',
        'function approve(address to, uint256 tokenId) public'
      ]

      let token = new this.ethers.Contract(this.launchAddress, abi, this.signer)

      let amount1 = await token.balanceOf(this.ethereumAddress)
      let amount2 = await token.balanceOf(this.recipientAddress)
      console.log('Balance #1: ', amount1.toNumber())
      console.log('Balance #2: ', amount2.toNumber())

      let approve = await token.approve(this.recipientAddress, this.tokenID.toString())
      let tx = await token.safeTransferFrom(this.ethereumAddress, this.recipientAddress, this.tokenID.toString())

      this.showLoading = true
      let val = await tx.wait()
      this.showLoading = false

      amount1 = await token.balanceOf(this.ethereumAddress)
      amount2 = await token.balanceOf(this.recipientAddress)
      console.log('Balance #1: ', amount1.toNumber())
      console.log('Balance #2: ', amount2.toNumber())

      await this.checkBalance()
    },
    resetLocalStorage(){
      localStorage.clear()
      location.reload()
    },
    goEtherscan(param){
      if (param.length == 42){
        window.open('https://rinkeby.etherscan.io/address/'+param)
      }else{
        window.open('https://rinkeby.etherscan.io/tx/'+param)
      }
    }
  },
  data() {
    return {
      contractFactoryAddress: null,
      name: 'Verify Non-Fungible Token',
      symbol: 'VNFT',
      launchHash: null,
      launchAddress: null,
      recipientAddress: null,
      tokenID: 1,
      tokenBalance: null,
      showLoading: false,
      bytecode: '60806040523480156200001157600080fd5b50604080518082018252601981527f566572696679204e6f6e2d46756e6769626c6520546f6b656e00000000000000602080830191909152825180840190935260048352631593919560e21b90830152906200007d6301ffc9a760e01b6001600160e01b036200010216565b81516200009290600690602085019062000187565b508051620000a890600790602084019062000187565b50620000c46380ac58cd60e01b6001600160e01b036200010216565b620000df635b5e139f60e01b6001600160e01b036200010216565b620000fa63780e9d6360e01b6001600160e01b036200010216565b50506200022c565b6001600160e01b0319808216141562000162576040805162461bcd60e51b815260206004820152601c60248201527f4552433136353a20696e76616c696420696e7465726661636520696400000000604482015290519081900360640190fd5b6001600160e01b0319166000908152602081905260409020805460ff19166001179055565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f10620001ca57805160ff1916838001178555620001fa565b82800160010185558215620001fa579182015b82811115620001fa578251825591602001919060010190620001dd565b50620002089291506200020c565b5090565b6200022991905b8082111562000208576000815560010162000213565b90565b611cb5806200023c6000396000f3fe608060405234801561001057600080fd5b50600436106101165760003560e01c80636352211e116100a2578063a22cb46511610071578063a22cb4651461035c578063b88d4fde1461038a578063c87b56dd14610450578063d0def5211461046d578063e985e9c51461052357610116565b80636352211e146103095780636c0360eb1461032657806370a082311461032e57806395d89b411461035457610116565b806318160ddd116100e957806318160ddd1461023a57806323b872dd146102545780632f745c591461028a57806342842e0e146102b65780634f6ccce7146102ec57610116565b806301ffc9a71461011b57806306fdde0314610156578063081812fc146101d3578063095ea7b31461020c575b600080fd5b6101426004803603602081101561013157600080fd5b50356001600160e01b031916610551565b604080519115158252519081900360200190f35b61015e610574565b6040805160208082528351818301528351919283929083019185019080838360005b83811015610198578181015183820152602001610180565b50505050905090810190601f1680156101c55780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b6101f0600480360360208110156101e957600080fd5b503561060b565b604080516001600160a01b039092168252519081900360200190f35b6102386004803603604081101561022257600080fd5b506001600160a01b03813516906020013561066d565b005b610242610748565b60408051918252519081900360200190f35b6102386004803603606081101561026a57600080fd5b506001600160a01b03813581169160208101359091169060400135610759565b610242600480360360408110156102a057600080fd5b506001600160a01b0381351690602001356107b0565b610238600480360360608110156102cc57600080fd5b506001600160a01b038135811691602081013590911690604001356107e1565b6102426004803603602081101561030257600080fd5b50356107fc565b6101f06004803603602081101561031f57600080fd5b5035610818565b61015e610846565b6102426004803603602081101561034457600080fd5b50356001600160a01b03166108a7565b61015e61090f565b6102386004803603604081101561037257600080fd5b506001600160a01b0381351690602001351515610970565b610238600480360360808110156103a057600080fd5b6001600160a01b038235811692602081013590911691604082013591908101906080810160608201356401000000008111156103db57600080fd5b8201836020820111156103ed57600080fd5b8035906020019184600183028401116401000000008311171561040f57600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250929550610a75945050505050565b61015e6004803603602081101561046657600080fd5b5035610ad3565b6102426004803603604081101561048357600080fd5b6001600160a01b0382351691908101906040810160208201356401000000008111156104ae57600080fd5b8201836020820111156104c057600080fd5b803590602001918460018302840111640100000000831117156104e257600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250929550610d7a945050505050565b6101426004803603604081101561053957600080fd5b506001600160a01b0381358116916020013516610da8565b6001600160e01b0319811660009081526020819052604090205460ff165b919050565b60068054604080516020601f60026000196101006001881615020190951694909404938401819004810282018101909252828152606093909290918301828280156106005780601f106105d557610100808354040283529160200191610600565b820191906000526020600020905b8154815290600101906020018083116105e357829003601f168201915b505050505090505b90565b600061061682610dd6565b6106515760405162461bcd60e51b815260040180806020018281038252602c815260200180611b7e602c913960400191505060405180910390fd5b506000908152600460205260409020546001600160a01b031690565b600061067882610818565b9050806001600160a01b0316836001600160a01b031614156106cb5760405162461bcd60e51b8152600401808060200182810382526021815260200180611c2e6021913960400191505060405180910390fd5b806001600160a01b03166106dd610de9565b6001600160a01b031614806106fe57506106fe816106f9610de9565b610da8565b6107395760405162461bcd60e51b8152600401808060200182810382526038815260200180611ad16038913960400191505060405180910390fd5b6107438383610ded565b505050565b60006107546002610e5b565b905090565b61076a610764610de9565b82610e66565b6107a55760405162461bcd60e51b8152600401808060200182810382526031815260200180611c4f6031913960400191505060405180910390fd5b610743838383610f0a565b6001600160a01b03821660009081526001602052604081206107d8908363ffffffff61106816565b90505b92915050565b61074383838360405180602001604052806000815250610a75565b60008061081060028463ffffffff61107416565b509392505050565b60006107db82604051806060016040528060298152602001611b33602991396002919063ffffffff61109016565b60098054604080516020601f60026000196101006001881615020190951694909404938401819004810282018101909252828152606093909290918301828280156106005780601f106105d557610100808354040283529160200191610600565b60006001600160a01b0382166108ee5760405162461bcd60e51b815260040180806020018281038252602a815260200180611b09602a913960400191505060405180910390fd5b6001600160a01b03821660009081526001602052604090206107db90610e5b565b60078054604080516020601f60026000196101006001881615020190951694909404938401819004810282018101909252828152606093909290918301828280156106005780601f106105d557610100808354040283529160200191610600565b610978610de9565b6001600160a01b0316826001600160a01b031614156109de576040805162461bcd60e51b815260206004820152601960248201527f4552433732313a20617070726f766520746f2063616c6c657200000000000000604482015290519081900360640190fd5b80600560006109eb610de9565b6001600160a01b03908116825260208083019390935260409182016000908120918716808252919093529120805460ff191692151592909217909155610a2f610de9565b60408051841515815290516001600160a01b0392909216917f17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c319181900360200190a35050565b610a86610a80610de9565b83610e66565b610ac15760405162461bcd60e51b8152600401808060200182810382526031815260200180611c4f6031913960400191505060405180910390fd5b610acd848484846110a7565b50505050565b6060610ade82610dd6565b610b195760405162461bcd60e51b815260040180806020018281038252602f815260200180611bff602f913960400191505060405180910390fd5b60008281526008602090815260409182902080548351601f6002600019610100600186161502019093169290920491820184900484028101840190945280845260609392830182828015610bae5780601f10610b8357610100808354040283529160200191610bae565b820191906000526020600020905b815481529060010190602001808311610b9157829003601f168201915b505060095493945050505060026000196101006001841615020190911604610bd757905061056f565b805115610ca8576009816040516020018083805460018160011615610100020316600290048015610c3f5780601f10610c1d576101008083540402835291820191610c3f565b820191906000526020600020905b815481529060010190602001808311610c2b575b5050825160208401908083835b60208310610c6b5780518252601f199092019160209182019101610c4c565b6001836020036101000a0380198251168184511680821785525050505050509050019250505060405160208183030381529060405291505061056f565b6009610cb3846110f9565b6040516020018083805460018160011615610100020316600290048015610d115780601f10610cef576101008083540402835291820191610d11565b820191906000526020600020905b815481529060010190602001808311610cfd575b5050825160208401908083835b60208310610d3d5780518252601f199092019160209182019101610d1e565b6001836020036101000a03801982511681845116808217855250505050505090500192505050604051602081830303815290604052915050919050565b6000610d86600a6111d4565b6000610d92600a6111dd565b9050610d9e84826111e1565b6107d8818461131b565b6001600160a01b03918216600090815260056020908152604080832093909416825291909152205460ff1690565b60006107db60028363ffffffff61137e16565b3390565b600081815260046020526040902080546001600160a01b0319166001600160a01b0384169081179091558190610e2282610818565b6001600160a01b03167f8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b92560405160405180910390a45050565b60006107db826111dd565b6000610e7182610dd6565b610eac5760405162461bcd60e51b815260040180806020018281038252602c815260200180611aa5602c913960400191505060405180910390fd5b6000610eb783610818565b9050806001600160a01b0316846001600160a01b03161480610ef25750836001600160a01b0316610ee78461060b565b6001600160a01b0316145b80610f025750610f028185610da8565b949350505050565b826001600160a01b0316610f1d82610818565b6001600160a01b031614610f625760405162461bcd60e51b8152600401808060200182810382526029815260200180611bd66029913960400191505060405180910390fd5b6001600160a01b038216610fa75760405162461bcd60e51b8152600401808060200182810382526024815260200180611a816024913960400191505060405180910390fd5b610fb2838383610743565b610fbd600082610ded565b6001600160a01b0383166000908152600160205260409020610fe5908263ffffffff61138a16565b506001600160a01b038216600090815260016020526040902061100e908263ffffffff61139616565b506110216002828463ffffffff6113a216565b5080826001600160a01b0316846001600160a01b03167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef60405160405180910390a4505050565b60006107d883836113b8565b6000808080611083868661141c565b9097909650945050505050565b600061109d848484611497565b90505b9392505050565b6110b2848484610f0a565b6110be84848484611561565b610acd5760405162461bcd60e51b8152600401808060200182810382526032815260200180611a4f6032913960400191505060405180910390fd5b60608161111e57506040805180820190915260018152600360fc1b602082015261056f565b8160005b811561113657600101600a82049150611122565b60608167ffffffffffffffff8111801561114f57600080fd5b506040519080825280601f01601f19166020018201604052801561117a576020820181803683370190505b50859350905060001982015b83156111cb57600a840660300160f81b828280600190039350815181106111a957fe5b60200101906001600160f81b031916908160001a905350600a84049350611186565b50949350505050565b80546001019055565b5490565b6001600160a01b03821661123c576040805162461bcd60e51b815260206004820181905260248201527f4552433732313a206d696e7420746f20746865207a65726f2061646472657373604482015290519081900360640190fd5b61124581610dd6565b15611297576040805162461bcd60e51b815260206004820152601c60248201527f4552433732313a20746f6b656e20616c7265616479206d696e74656400000000604482015290519081900360640190fd5b6112a360008383610743565b6001600160a01b03821660009081526001602052604090206112cb908263ffffffff61139616565b506112de6002828463ffffffff6113a216565b5060405181906001600160a01b038416906000907fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef908290a45050565b61132482610dd6565b61135f5760405162461bcd60e51b815260040180806020018281038252602c815260200180611baa602c913960400191505060405180910390fd5b6000828152600860209081526040909120825161074392840190611994565b60006107d8838361179c565b60006107d883836117b4565b60006107d8838361187a565b600061109d84846001600160a01b0385166118c4565b815460009082106113fa5760405162461bcd60e51b8152600401808060200182810382526022815260200180611a2d6022913960400191505060405180910390fd5b82600001828154811061140957fe5b9060005260206000200154905092915050565b8154600090819083106114605760405162461bcd60e51b8152600401808060200182810382526022815260200180611b5c6022913960400191505060405180910390fd5b600084600001848154811061147157fe5b906000526020600020906002020190508060000154816001015492509250509250929050565b600082815260018401602052604081205482816115325760405162461bcd60e51b81526004018080602001828103825283818151815260200191508051906020019080838360005b838110156114f75781810151838201526020016114df565b50505050905090810190601f1680156115245780820380516001836020036101000a031916815260200191505b509250505060405180910390fd5b5084600001600182038154811061154557fe5b9060005260206000209060020201600101549150509392505050565b6000611575846001600160a01b031661195b565b61158157506001610f02565b600060606001600160a01b038616630a85bd0160e11b61159f610de9565b89888860405160240180856001600160a01b03166001600160a01b03168152602001846001600160a01b03166001600160a01b0316815260200183815260200180602001828103825283818151815260200191508051906020019080838360005b83811015611618578181015183820152602001611600565b50505050905090810190601f1680156116455780820380516001836020036101000a031916815260200191505b5060408051601f198184030181529181526020820180516001600160e01b03166001600160e01b0319909a16999099178952518151919890975087965094509250829150849050835b602083106116ad5780518252601f19909201916020918201910161168e565b6001836020036101000a0380198251168184511680821785525050505050509050019150506000604051808303816000865af19150503d806000811461170f576040519150601f19603f3d011682016040523d82523d6000602084013e611714565b606091505b5091509150816117655780511561172e5780518082602001fd5b60405162461bcd60e51b8152600401808060200182810382526032815260200180611a4f6032913960400191505060405180910390fd5b600081806020019051602081101561177c57600080fd5b50516001600160e01b031916630a85bd0160e11b149350610f0292505050565b60009081526001919091016020526040902054151590565b6000818152600183016020526040812054801561187057835460001980830191908101906000908790839081106117e757fe5b906000526020600020015490508087600001848154811061180457fe5b60009182526020808320909101929092558281526001898101909252604090209084019055865487908061183457fe5b600190038181906000526020600020016000905590558660010160008781526020019081526020016000206000905560019450505050506107db565b60009150506107db565b6000611886838361179c565b6118bc575081546001818101845560008481526020808220909301849055845484825282860190935260409020919091556107db565b5060006107db565b6000828152600184016020526040812054806119295750506040805180820182528381526020808201848152865460018181018955600089815284812095516002909302909501918255915190820155865486845281880190925292909120556110a0565b8285600001600183038154811061193c57fe5b90600052602060002090600202016001018190555060009150506110a0565b6000813f7fc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470818114801590610f02575050151592915050565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f106119d557805160ff1916838001178555611a02565b82800160010185558215611a02579182015b82811115611a025782518255916020019190600101906119e7565b50611a0e929150611a12565b5090565b61060891905b80821115611a0e5760008155600101611a1856fe456e756d657261626c655365743a20696e646578206f7574206f6620626f756e64734552433732313a207472616e7366657220746f206e6f6e20455243373231526563656976657220696d706c656d656e7465724552433732313a207472616e7366657220746f20746865207a65726f20616464726573734552433732313a206f70657261746f7220717565727920666f72206e6f6e6578697374656e7420746f6b656e4552433732313a20617070726f76652063616c6c6572206973206e6f74206f776e6572206e6f7220617070726f76656420666f7220616c6c4552433732313a2062616c616e636520717565727920666f7220746865207a65726f20616464726573734552433732313a206f776e657220717565727920666f72206e6f6e6578697374656e7420746f6b656e456e756d657261626c654d61703a20696e646578206f7574206f6620626f756e64734552433732313a20617070726f76656420717565727920666f72206e6f6e6578697374656e7420746f6b656e4552433732314d657461646174613a2055524920736574206f66206e6f6e6578697374656e7420746f6b656e4552433732313a207472616e73666572206f6620746f6b656e2074686174206973206e6f74206f776e4552433732314d657461646174613a2055524920717565727920666f72206e6f6e6578697374656e7420746f6b656e4552433732313a20617070726f76616c20746f2063757272656e74206f776e65724552433732313a207472616e736665722063616c6c6572206973206e6f74206f776e6572206e6f7220617070726f766564a2646970667358221220545e09a1e3b1bbe346e6d7ce7c188f23626ef52f97a31e7230188952bf7e932064736f6c63430006070033',

      abi: [
        {
          "inputs": [],
          "stateMutability": "nonpayable",
          "type": "constructor"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": true,
              "internalType": "address",
              "name": "owner",
              "type": "address"
            },
            {
              "indexed": true,
              "internalType": "address",
              "name": "approved",
              "type": "address"
            },
            {
              "indexed": true,
              "internalType": "uint256",
              "name": "tokenId",
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
              "name": "owner",
              "type": "address"
            },
            {
              "indexed": true,
              "internalType": "address",
              "name": "operator",
              "type": "address"
            },
            {
              "indexed": false,
              "internalType": "bool",
              "name": "approved",
              "type": "bool"
            }
          ],
          "name": "ApprovalForAll",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": true,
              "internalType": "address",
              "name": "from",
              "type": "address"
            },
            {
              "indexed": true,
              "internalType": "address",
              "name": "to",
              "type": "address"
            },
            {
              "indexed": true,
              "internalType": "uint256",
              "name": "tokenId",
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
              "name": "to",
              "type": "address"
            },
            {
              "internalType": "uint256",
              "name": "tokenId",
              "type": "uint256"
            }
          ],
          "name": "approve",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "address",
              "name": "owner",
              "type": "address"
            }
          ],
          "name": "balanceOf",
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
          "name": "baseURI",
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
          "inputs": [
            {
              "internalType": "uint256",
              "name": "tokenId",
              "type": "uint256"
            }
          ],
          "name": "getApproved",
          "outputs": [
            {
              "internalType": "address",
              "name": "",
              "type": "address"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "address",
              "name": "owner",
              "type": "address"
            },
            {
              "internalType": "address",
              "name": "operator",
              "type": "address"
            }
          ],
          "name": "isApprovedForAll",
          "outputs": [
            {
              "internalType": "bool",
              "name": "",
              "type": "bool"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "address",
              "name": "to",
              "type": "address"
            },
            {
              "internalType": "string",
              "name": "tokenURI",
              "type": "string"
            }
          ],
          "name": "mint",
          "outputs": [
            {
              "internalType": "uint256",
              "name": "",
              "type": "uint256"
            }
          ],
          "stateMutability": "nonpayable",
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
          "inputs": [
            {
              "internalType": "uint256",
              "name": "tokenId",
              "type": "uint256"
            }
          ],
          "name": "ownerOf",
          "outputs": [
            {
              "internalType": "address",
              "name": "",
              "type": "address"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "address",
              "name": "from",
              "type": "address"
            },
            {
              "internalType": "address",
              "name": "to",
              "type": "address"
            },
            {
              "internalType": "uint256",
              "name": "tokenId",
              "type": "uint256"
            }
          ],
          "name": "safeTransferFrom",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "address",
              "name": "operator",
              "type": "address"
            },
            {
              "internalType": "bool",
              "name": "approved",
              "type": "bool"
            }
          ],
          "name": "setApprovalForAll",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "bytes4",
              "name": "interfaceId",
              "type": "bytes4"
            }
          ],
          "name": "supportsInterface",
          "outputs": [
            {
              "internalType": "bool",
              "name": "",
              "type": "bool"
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
          "inputs": [
            {
              "internalType": "uint256",
              "name": "index",
              "type": "uint256"
            }
          ],
          "name": "tokenByIndex",
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
              "name": "owner",
              "type": "address"
            },
            {
              "internalType": "uint256",
              "name": "index",
              "type": "uint256"
            }
          ],
          "name": "tokenOfOwnerByIndex",
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
              "internalType": "uint256",
              "name": "tokenId",
              "type": "uint256"
            }
          ],
          "name": "tokenURI",
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
              "name": "from",
              "type": "address"
            },
            {
              "internalType": "address",
              "name": "to",
              "type": "address"
            },
            {
              "internalType": "uint256",
              "name": "tokenId",
              "type": "uint256"
            }
          ],
          "name": "transferFrom",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        }
      ]
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

a {
  color: blue;
}
a:hover {
  cursor: pointer;
  color: blue;
  font-weight: bold;
}


.links {
  padding-top: 15px;
}
</style>