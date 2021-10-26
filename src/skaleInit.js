//import { IMA } from '@skalenetwork/ima-js';
const IMA = require('@skalenetwork/ima-js');

//import mainnetAbi from './mainnetAbi.json'; // your local sources
//import schainAbi from './schainAbi.json'; // your local sources

//const MAINNET_ENDPOINT = '[YOUR_ETHEREUM_MAINNET_ENDPOINT]';
//const SCHAIN_ENDPOINT = '[YOUR_SCHAIN_ENDPOINT]';

//const mainnetWeb3 = new Web3(MAINNET_ENDPOINT);
//const sChainWeb3 = new Web3(SCHAIN_ENDPOINT);

//let ima = new IMA(mainnetWeb3, sChainWeb3, mainnetAbi, sChainAbi);

module.exports = async function(deployer, network, accounts) {
  console.log(network)
}
