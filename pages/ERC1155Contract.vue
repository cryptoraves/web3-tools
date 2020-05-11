<template>
  <div class="container">
    <div>
      <h1 class="title">
        ERC1155 Contract
      </h1>
      <div>
        <h2 class="subtitle">
          Tinker with 1155 contract
       </h2>
       <div class="content">
          <a
            target="_blank" 
            @click="goEtherscan(ethereumAddress)">
            Wallet Address: {{ this.ethereumAddress }}
          </a>
          <br>
          <div
            v-if="ethereumAddress && !contractFactoryAddress" 
            class="links">
            <a
              @click="launchFactory()"
              class="button--green"
            >
              Launch 1155 Contract
            </a>
          </div>
          <br>
            <a v-if="contractFactoryAddress"
              target="_blank" 
              @click="goEtherscan(contractFactoryAddress)">
              New Contract Address: {{ this.contractFactoryAddress }}
            </a>
            <div 
              v-if="contractFactoryAddress"
              class="links">
              <form name="contact" action="" method="post">
                <label for="ethereumAddress">
                  Address To:
                </label>
                <input v-model="ethereumAddress"/>
                <br>
                <label for="tokenId">
                  Token ID:
                </label>
                <input v-model="tokenId"/>
                <br>
                <label for="amount">
                  Value:
                </label>
                <input v-model="amount"/>
                <br>
                <label for="decimals">
                  decimals:
                </label>
                <input v-model="decimals"/>
                <br>
                <label for="data">
                  data:
                </label>
                <input v-model="data" disabled/>
                <br>
                <div
                  class="links">
                  <a
                    @click="launchToken()"
                    class="button--green"
                  >
                    Mint New Token(s)
                  </a>
                </div>         
              </form>
            </div>
          <br>
          <form v-if="minted && !showLoading" name="send" action="" method="post">
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
            <div 
              class="links">
              <a
                @click="sendToken()"
                class="button--green"
              >
                Send {{this.amount}} of {{ this.symbol }} tokens to: {{ this.recipientAddress}}
              </a>
            </div>      
          </form>
          
          <div
            v-if="showLoading"
          >
            <img 
              src="../assets/gif/loading.gif" 
              alt >
          </div>
          <div 
            v-if="contractFactoryAddress"
            class="links">
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
  </div>
</template>

<script>

import MetamaskHandler from "./metamaskHandler"

export default {
  extends: MetamaskHandler,
  components: {},
  async mounted() {
    //localStorage.contractFactoryAddress = '0x471FE61C929c03F534E32af51509DA308D911C3f' original factory address
    if (localStorage.ERC1155launchHash) this.launchHash = localStorage.ERC1155launchHash
    if (localStorage.ERC1155recipientAddress) this.recipientAddress = localStorage.ERC1155recipientAddress
    if (localStorage.ERC1155contractFactoryAddress) this.contractFactoryAddress = localStorage.ERC1155contractFactoryAddress
    if (localStorage.ERC1155minted) this.minted = localStorage.ERC1155minted
    if (this.minted) this.amount = 100
  },
  methods: {
    async initializeWallet(){
      //this.wallet = new this.ethers.Wallet.createRandom()
      //this.wallet = new this.ethers.Wallet.fromMnemonic('wrist great knee profit inject clutch perfect purse faith lens vacuum world')
      //this.wallet = this.wallet.connect(this.ethereumProvider)
    },
    async launchFactory(){

      let factory = new this.ethers.ContractFactory(this.abi, this.bytecode, this.signer);

      
      let contract = await factory.deploy();

      this.showLoading = true
      await contract.deployed()
      this.showLoading = false

      this.contractFactoryAddress = localStorage.ERC1155contractFactoryAddress = contract.address
    },
    async launchToken(){

      let token = new this.ethers.Contract(
        this.contractFactoryAddress, 
        this.abi, 
        this.signer
      )

      let amt = this.ethers.utils.parseUnits(this.amount.toString(), parseInt(this.decimals))
      
      let tx = await token.mint(
        this.ethereumAddress,
        this.tokenId,
        amt.toString(),
        this.ethers.utils.formatBytes32String(this.data)
      )
      this.showLoading = true
      let val = await tx.wait()
      this.showLoading = false

      let recipient = new this.ethers.Wallet.createRandom()
      this.recipientAddress = localStorage.ERC1155recipientAddress = recipient.address

      let amount1 = await token.balanceOf(this.ethereumAddress, this.tokenId)
      console.log('Balance #1: ', this.ethers.utils.formatUnits(amount1, this.decimals))

      this.minted = localStorage.ERC1155minted = true
      this.amount = 100
    },
    async sendToken(){

      let abi = [
        'function balanceOf(address from, uint256 tokenId) external view returns (uint256)',
        'function safeTransferFrom(address from, address to, uint256 tokenId, uint256 value, bytes data) public',
      ]
      console.log('here')
      let token = new this.ethers.Contract(this.contractFactoryAddress, abi, this.signer)
      console.log('here')
      let amount1 = await token.balanceOf(this.ethereumAddress, this.tokenId)
      let amount2 = await token.balanceOf(this.recipientAddress, this.tokenId)
      console.log('Balance #1: ', this.ethers.utils.formatUnits(amount1, this.decimals))
      console.log('Balance #2: ', this.ethers.utils.formatUnits(amount2, this.decimals))
      
      let tx = await token.safeTransferFrom(this.ethereumAddress, this.recipientAddress,this.tokenId, this.ethers.utils.parseEther(this.amount.toString()), this.ethers.utils.formatBytes32String(this.data))

      this.showLoading = true
      let val = await tx.wait()
      this.showLoading = false

      amount1 = await token.balanceOf(this.ethereumAddress, this.tokenId)
      amount2 = await token.balanceOf(this.recipientAddress, this.tokenId)
      console.log('Balance #1: ', this.ethers.utils.formatUnits(amount1, this.decimals))
      console.log('Balance #2: ', this.ethers.utils.formatUnits(amount2, this.decimals))
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
      name: 'BigToken1155',
      symbol: 'BTK1',
      launchHash: null,
      launchAddress: null,
      recipientAddress: null,
      amount: 1000000000,
      decimals: 18,
      tokenId: 0,
      data: '',
      showLoading: false,
      minted: false,
      bytecode: '608060405234801561001057600080fd5b5061002a6301ffc9a760e01b6001600160e01b0361004816565b610043636cdb3d1360e11b6001600160e01b0361004816565b6100cc565b6001600160e01b031980821614156100a7576040805162461bcd60e51b815260206004820152601c60248201527f4552433136353a20696e76616c696420696e7465726661636520696400000000604482015290519081900360640190fd5b6001600160e01b0319166000908152602081905260409020805460ff19166001179055565b611a20806100db6000396000f3fe608060405234801561001057600080fd5b50600436106100925760003560e01c80634e1273f4116100665780634e1273f4146103f1578063731133e914610564578063a22cb46514610624578063e985e9c514610652578063f242432a1461068057610092565b8062fdd58e1461009757806301ffc9a7146100d55780631f7fdffa146101105780632eb2c2d6146102ca575b600080fd5b6100c3600480360360408110156100ad57600080fd5b506001600160a01b038135169060200135610713565b60408051918252519081900360200190f35b6100fc600480360360208110156100eb57600080fd5b50356001600160e01b031916610782565b604080519115158252519081900360200190f35b6102c86004803603608081101561012657600080fd5b6001600160a01b038235169190810190604081016020820135600160201b81111561015057600080fd5b82018360208201111561016257600080fd5b803590602001918460208302840111600160201b8311171561018357600080fd5b9190808060200260200160405190810160405280939291908181526020018383602002808284376000920191909152509295949360208101935035915050600160201b8111156101d257600080fd5b8201836020820111156101e457600080fd5b803590602001918460208302840111600160201b8311171561020557600080fd5b9190808060200260200160405190810160405280939291908181526020018383602002808284376000920191909152509295949360208101935035915050600160201b81111561025457600080fd5b82018360208201111561026657600080fd5b803590602001918460018302840111600160201b8311171561028757600080fd5b91908080601f0160208091040260200160405190810160405280939291908181526020018383808284376000920191909152509295506107a1945050505050565b005b6102c8600480360360a08110156102e057600080fd5b6001600160a01b038235811692602081013590911691810190606081016040820135600160201b81111561031357600080fd5b82018360208201111561032557600080fd5b803590602001918460208302840111600160201b8311171561034657600080fd5b919390929091602081019035600160201b81111561036357600080fd5b82018360208201111561037557600080fd5b803590602001918460208302840111600160201b8311171561039657600080fd5b919390929091602081019035600160201b8111156103b357600080fd5b8201836020820111156103c557600080fd5b803590602001918460018302840111600160201b831117156103e657600080fd5b5090925090506107b3565b6105146004803603604081101561040757600080fd5b810190602081018135600160201b81111561042157600080fd5b82018360208201111561043357600080fd5b803590602001918460208302840111600160201b8311171561045457600080fd5b9190808060200260200160405190810160405280939291908181526020018383602002808284376000920191909152509295949360208101935035915050600160201b8111156104a357600080fd5b8201836020820111156104b557600080fd5b803590602001918460208302840111600160201b831117156104d657600080fd5b919080806020026020016040519081016040528093929190818152602001838360200280828437600092019190915250929550610b3d945050505050565b60408051602080825283518183015283519192839290830191858101910280838360005b83811015610550578181015183820152602001610538565b505050509050019250505060405180910390f35b6102c86004803603608081101561057a57600080fd5b6001600160a01b038235169160208101359160408201359190810190608081016060820135600160201b8111156105b057600080fd5b8201836020820111156105c257600080fd5b803590602001918460018302840111600160201b831117156105e357600080fd5b91908080601f016020809104026020016040519081016040528093929190818152602001838380828437600092019190915250929550610cbb945050505050565b6102c86004803603604081101561063a57600080fd5b506001600160a01b0381351690602001351515610cc7565b6100fc6004803603604081101561066857600080fd5b506001600160a01b0381358116916020013516610d7d565b6102c8600480360360a081101561069657600080fd5b6001600160a01b03823581169260208101359091169160408201359160608101359181019060a081016080820135600160201b8111156106d557600080fd5b8201836020820111156106e757600080fd5b803590602001918460018302840111600160201b8311171561070857600080fd5b509092509050610dab565b60006001600160a01b03831661075a5760405162461bcd60e51b815260040180806020018281038252602b815260200180611758602b913960400191505060405180910390fd5b5060009081526001602090815260408083206001600160a01b03949094168352929052205490565b6001600160e01b03191660009081526020819052604090205460ff1690565b6107ad84848484610f83565b50505050565b8483146107f15760405162461bcd60e51b815260040180806020018281038252602e8152602001806118d2602e913960400191505060405180910390fd5b6001600160a01b0387166108365760405162461bcd60e51b81526004018080602001828103825260288152602001806117836028913960400191505060405180910390fd5b6001600160a01b03881633148061085857506108528833610d7d565b15156001145b6108935760405162461bcd60e51b815260040180806020018281038252603781526020018061189b6037913960400191505060405180910390fd5b60005b858110156109dd5760008787838181106108ac57fe5b90506020020135905060008686848181106108c357fe5b90506020020135905061092f816040518060600160405280603d815260200161197d603d91396001600086815260200190815260200160002060008f6001600160a01b03166001600160a01b03168152602001908152602001600020546111b69092919063ffffffff16565b6001600084815260200190815260200160002060008d6001600160a01b03166001600160a01b03168152602001908152602001600020819055506109b2816001600085815260200190815260200160002060008d6001600160a01b03166001600160a01b031681526020019081526020016000205461124d90919063ffffffff16565b60009283526001602081815260408086206001600160a01b038f168752909152909320555001610896565b50866001600160a01b0316886001600160a01b0316336001600160a01b03167f4a39dc06d4c0dbc64b70af90fd698a233a518aa5d07e595d983b8c0526c8f7fb898989896040518080602001806020018381038352878782818152602001925060200280828437600083820152601f01601f19169091018481038352858152602090810191508690860280828437600083820152604051601f909101601f19169092018290039850909650505050505050a4610b3333898989898080602002602001604051908101604052809392919081815260200183836020028082843760009201919091525050604080516020808d0282810182019093528c82529093508c92508b91829185019084908082843760009201919091525050604080516020601f8c018190048102820181019092528a815292508a91508990819084018382808284376000920191909152506112ae92505050565b5050505050505050565b60608151835114610b7f5760405162461bcd60e51b81526004018080602001828103825260308152602001806117d76030913960400191505060405180910390fd5b6060835167ffffffffffffffff81118015610b9957600080fd5b50604051908082528060200260200182016040528015610bc3578160200160208202803683370190505b50905060005b8451811015610cb35760006001600160a01b0316858281518110610be957fe5b60200260200101516001600160a01b03161415610c375760405162461bcd60e51b815260040180806020018281038252603481526020018061183d6034913960400191505060405180910390fd5b60016000858381518110610c4757fe5b602002602001015181526020019081526020016000206000868381518110610c6b57fe5b60200260200101516001600160a01b03166001600160a01b0316815260200190815260200160002054828281518110610ca057fe5b6020908102919091010152600101610bc9565b509392505050565b6107ad848484846114b1565b336001600160a01b0383161415610d0f5760405162461bcd60e51b815260040180806020018281038252602c8152602001806117ab602c913960400191505060405180910390fd5b3360008181526002602090815260408083206001600160a01b03871680855290835292819020805460ff1916861515908117909155815190815290519293927f17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31929181900390910190a35050565b6001600160a01b03918216600090815260026020908152604080832093909416825291909152205460ff1690565b6001600160a01b038516610df05760405162461bcd60e51b81526004018080602001828103825260288152602001806117836028913960400191505060405180910390fd5b6001600160a01b038616331480610e125750610e0c8633610d7d565b15156001145b610e4d5760405162461bcd60e51b815260040180806020018281038252603781526020018061189b6037913960400191505060405180910390fd5b610e9a836040518060600160405280602a8152602001611871602a913960008781526001602090815260408083206001600160a01b038d168452909152902054919063ffffffff6111b616565b60008581526001602090815260408083206001600160a01b038b81168552925280832093909355871681522054610ed1908461124d565b60008581526001602090815260408083206001600160a01b03808b16808652918452938290209490945580518881529182018790528051928a169233927fc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f6292908290030190a4610f7b338787878787878080601f01602080910402602001604051908101604052809392919081815260200183838082843760009201919091525061159492505050565b505050505050565b6001600160a01b038416610fc85760405162461bcd60e51b81526004018080602001828103825260278152602001806119356027913960400191505060405180910390fd5b81518351146110085760405162461bcd60e51b81526004018080602001828103825260358152602001806119006035913960400191505060405180910390fd5b60005b83518110156110cc576110836001600086848151811061102757fe5b602002602001015181526020019081526020016000206000876001600160a01b03166001600160a01b031681526020019081526020016000205484838151811061106d57fe5b602002602001015161124d90919063ffffffff16565b6001600086848151811061109357fe5b602090810291909101810151825281810192909252604090810160009081206001600160a01b038a16825290925290205560010161100b565b50836001600160a01b031660006001600160a01b0316336001600160a01b03167f4a39dc06d4c0dbc64b70af90fd698a233a518aa5d07e595d983b8c0526c8f7fb8686604051808060200180602001838103835285818151815260200191508051906020019060200280838360005b8381101561115357818101518382015260200161113b565b50505050905001838103825284818151815260200191508051906020019060200280838360005b8381101561119257818101518382015260200161117a565b5050505090500194505050505060405180910390a46107ad336000868686866112ae565b600081848411156112455760405162461bcd60e51b81526004018080602001828103825283818151815260200191508051906020019080838360005b8381101561120a5781810151838201526020016111f2565b50505050905090810190601f1680156112375780820380516001836020036101000a031916815260200191505b509250505060405180910390fd5b505050900390565b6000828201838110156112a7576040805162461bcd60e51b815260206004820152601b60248201527f536166654d6174683a206164646974696f6e206f766572666c6f770000000000604482015290519081900360640190fd5b9392505050565b6112c0846001600160a01b031661171b565b15610f7b5763bc197c8160e01b6001600160e01b031916846001600160a01b031663bc197c8188888787876040518663ffffffff1660e01b815260040180866001600160a01b03166001600160a01b03168152602001856001600160a01b03166001600160a01b03168152602001806020018060200180602001848103845287818151815260200191508051906020019060200280838360005b8381101561137257818101518382015260200161135a565b50505050905001848103835286818151815260200191508051906020019060200280838360005b838110156113b1578181015183820152602001611399565b50505050905001848103825285818151815260200191508051906020019080838360005b838110156113ed5781810151838201526020016113d5565b50505050905090810190601f16801561141a5780820380516001836020036101000a031916815260200191505b5098505050505050505050602060405180830381600087803b15801561143f57600080fd5b505af1158015611453573d6000803e3d6000fd5b505050506040513d602081101561146957600080fd5b50516001600160e01b03191614610f7b5760405162461bcd60e51b81526004018080602001828103825260368152602001806118076036913960400191505060405180910390fd5b6001600160a01b0384166114f65760405162461bcd60e51b815260040180806020018281038252602181526020018061195c6021913960400191505060405180910390fd5b60008381526001602090815260408083206001600160a01b0388168452909152902054611529908363ffffffff61124d16565b60008481526001602090815260408083206001600160a01b038916808552908352818420949094558051878152918201869052805133927fc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f6292908290030190a46107ad336000868686865b6115a6846001600160a01b031661171b565b15610f7b5763f23a6e6160e01b6001600160e01b031916846001600160a01b031663f23a6e6188888787876040518663ffffffff1660e01b815260040180866001600160a01b03166001600160a01b03168152602001856001600160a01b03166001600160a01b0316815260200184815260200183815260200180602001828103825283818151815260200191508051906020019080838360005b83811015611659578181015183820152602001611641565b50505050905090810190601f1680156116865780820380516001836020036101000a031916815260200191505b509650505050505050602060405180830381600087803b1580156116a957600080fd5b505af11580156116bd573d6000803e3d6000fd5b505050506040513d60208110156116d357600080fd5b50516001600160e01b03191614610f7b5760405162461bcd60e51b81526004018080602001828103825260318152602001806119ba6031913960400191505060405180910390fd5b6000813f7fc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a47081811480159061174f57508115155b94935050505056fe455243313135353a2062616c616e636520717565727920666f7220746865207a65726f2061646472657373455243313135353a207461726765742061646472657373206d757374206265206e6f6e2d7a65726f455243313135353a2063616e6e6f742073657420617070726f76616c2073746174757320666f722073656c66455243313135353a206163636f756e747320616e6420494473206d75737420686176652073616d65206c656e67746873455243313135353a20676f7420756e6b6e6f776e2076616c75652066726f6d206f6e4552433131353542617463685265636569766564455243313135353a20736f6d65206164647265737320696e2062617463682062616c616e6365207175657279206973207a65726f455243313135353a20696e73756666696369656e742062616c616e636520666f72207472616e73666572455243313135353a206e656564206f70657261746f7220617070726f76616c20666f7220337264207061727479207472616e7366657273455243313135353a2049447320616e642076616c756573206d75737420686176652073616d65206c656e67746873455243313135353a206d696e7465642049447320616e642076616c756573206d75737420686176652073616d65206c656e67746873455243313135353a206261746368206d696e7420746f20746865207a65726f2061646472657373455243313135353a206d696e7420746f20746865207a65726f2061646472657373455243313135353a20696e73756666696369656e742062616c616e6365206f6620736f6d6520746f6b656e207479706520666f72207472616e73666572455243313135353a20676f7420756e6b6e6f776e2076616c75652066726f6d206f6e455243313135355265636569766564a2646970667358221220161a1760a87c0fdd1f9e94112a051a764ba7e13c82c5bea8d5d04e975dd2a6d664736f6c63430006070033',

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
              "name": "account",
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
              "name": "operator",
              "type": "address"
            },
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
              "indexed": false,
              "internalType": "uint256[]",
              "name": "ids",
              "type": "uint256[]"
            },
            {
              "indexed": false,
              "internalType": "uint256[]",
              "name": "values",
              "type": "uint256[]"
            }
          ],
          "name": "TransferBatch",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": true,
              "internalType": "address",
              "name": "operator",
              "type": "address"
            },
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
              "indexed": false,
              "internalType": "uint256",
              "name": "id",
              "type": "uint256"
            },
            {
              "indexed": false,
              "internalType": "uint256",
              "name": "value",
              "type": "uint256"
            }
          ],
          "name": "TransferSingle",
          "type": "event"
        },
        {
          "anonymous": false,
          "inputs": [
            {
              "indexed": false,
              "internalType": "string",
              "name": "value",
              "type": "string"
            },
            {
              "indexed": true,
              "internalType": "uint256",
              "name": "id",
              "type": "uint256"
            }
          ],
          "name": "URI",
          "type": "event"
        },
        {
          "inputs": [
            {
              "internalType": "address",
              "name": "account",
              "type": "address"
            },
            {
              "internalType": "uint256",
              "name": "id",
              "type": "uint256"
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
          "inputs": [
            {
              "internalType": "address[]",
              "name": "accounts",
              "type": "address[]"
            },
            {
              "internalType": "uint256[]",
              "name": "ids",
              "type": "uint256[]"
            }
          ],
          "name": "balanceOfBatch",
          "outputs": [
            {
              "internalType": "uint256[]",
              "name": "",
              "type": "uint256[]"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "address",
              "name": "account",
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
              "name": "_to",
              "type": "address"
            },
            {
              "internalType": "uint256",
              "name": "_id",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "_value",
              "type": "uint256"
            },
            {
              "internalType": "bytes",
              "name": "_data",
              "type": "bytes"
            }
          ],
          "name": "mint",
          "outputs": [],
          "stateMutability": "nonpayable",
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
              "internalType": "uint256[]",
              "name": "_ids",
              "type": "uint256[]"
            },
            {
              "internalType": "uint256[]",
              "name": "_values",
              "type": "uint256[]"
            },
            {
              "internalType": "bytes",
              "name": "_data",
              "type": "bytes"
            }
          ],
          "name": "mintBatch",
          "outputs": [],
          "stateMutability": "nonpayable",
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
              "internalType": "uint256[]",
              "name": "ids",
              "type": "uint256[]"
            },
            {
              "internalType": "uint256[]",
              "name": "values",
              "type": "uint256[]"
            },
            {
              "internalType": "bytes",
              "name": "data",
              "type": "bytes"
            }
          ],
          "name": "safeBatchTransferFrom",
          "outputs": [],
          "stateMutability": "nonpayable",
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
              "name": "id",
              "type": "uint256"
            },
            {
              "internalType": "uint256",
              "name": "value",
              "type": "uint256"
            },
            {
              "internalType": "bytes",
              "name": "data",
              "type": "bytes"
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