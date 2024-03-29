/**
 * Use this file to configure your truffle project. It's seeded with some
 * common settings for different networks and features like migrations,
 * compilation and testing. Uncomment the ones you need or modify
 * them to suit your project as necessary.
 *
 * More information about configuration can be found at:
 *
 * truffleframework.com/docs/advanced/configuration
 *
 * To deploy via Infura you'll need a wallet provider (like @truffle/hdwallet-provider)
 * to sign your transactions before they're sent to a remote public node. Infura accounts
 * are available for free at: infura.io/register.
 *
 * You'll also need a mnemonic - the twelve word phrase the wallet uses to generate
 * public/private key pairs. If you're publishing your code to GitHub make sure you load this
 * phrase from a file you've .gitignored so it doesn't accidentally become public.



 *  ganache-cli -h 0.0.0.0 -l 20000000 -a 61 -m "cabin regret chest donate above loop type forget pond equip physical like"
 */

const HDWalletProvider = require("@truffle/hdwallet-provider");
const fs = require("fs");
const privateKey = fs
  .readFileSync(".prvkey")
  .toString()
  .trim();
const infuraKey = fs
  .readFileSync(".infuraKey")
  .toString()
  .trim();
//const fs = require('fs');
//const mnemonic = fs.readFileSync(".secret").toString().trim();
//const infuraKey = fs.readFileSync(".infuraKey").toString().trim();
process.env.UV_THREADPOOL_SIZE = 128;
module.exports = {
  /**
   * Networks define how you connect to your ethereum client and let you set the
   * defaults web3 uses to send transactions. If you don't specify one truffle
   * will spin up a development blockchain for you on port 9545 when you
   * run `develop` or `test`. You can ask a truffle command to use a specific
   * network from the command line, e.g
   *
   * $ truffle test --network <network-name>
   */

  networks: {
    // Useful for testing. The `development` name is special - truffle uses it by default
    // if it's defined here and no other network is specified at the command line.
    // You should run a client (like ganache-cli, geth or parity) in a separate terminal
    // tab if you use this network and you must also set the `host`, `port` and `network_id`
    // options below to some value.
    //
    development: {
      host: "127.0.0.1", // Localhost (default: none)
      port: 8545, // Standard Ethereum port (default: none)
      network_id: "*", // Any network (default: none)
      gas: 20000000
    },
    homestead: {
      host: "0.0.0.0", // Localhost (default: none)
      port: 8545, // Standard Ethereum port (default: none)
      network_id: "*", // Any network (default: none)
      gas: 20000000
    },

    // Another network with more advanced options...
    // advanced: {
    // port: 8777,             // Custom port
    // network_id: 1342,       // Custom network
    // gas: 8500000,           // Gas sent with each transaction (default: ~6700000)
    // gasPrice: 20000000000,  // 20 gwei (in wei) (default: 100 gwei)
    // from: <address>,        // Account to send txs from (default: accounts[0])
    // websockets: true        // Enable EventEmitter interface for web3 (default: false)
    // },

    // Useful for deploying to a public network.
    // NB: It's important to wrap the provider as a function.
    rinkeby: {
      provider: () =>
        new HDWalletProvider(
          privateKey,
          "https://rinkeby.infura.io/v3/" + infuraKey
        ),
      network_id: 4, // Ropsten's id
      gas: 29970705, // Ropsten has a lower block limit than mainnet
      confirmations: 2, // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 400, // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: false // Skip dry run before migrations? (default: false for public nets )
    },
    goerli: {
      provider: () =>
        new HDWalletProvider(
          privateKey,
          "https://goerli.infura.io/v3/" + infuraKey
        ),
      network_id: 5, // goerli's id
      gas: 5500000, // goerli has a lower block limit than mainnet
      confirmations: 2, // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200 // # of blocks before a deployment times out  (minimum/default: 50)
    },

    skaleTest: {
      provider: () =>
        new HDWalletProvider(
          privateKey,
          "https://dev-testnet-v1-0.skalelabs.com"
        ),
      gasPrice: 0,
      gas: 40000000,
      network_id: "*",
      ChainID: 344435,
      skipDryRun: true
    },
    skaleTestBob: {
      provider: () =>
        new HDWalletProvider(
          privateKey,
          "https://dev-testnet-v1-1.skalelabs.com"
        ),
      gasPrice: 0,
      gas: 40000000,
      network_id: "*",
      timeout: 100000,
      ChainID: 344435,
      skipDryRun: true
    },
    maticTest: {
      provider: () =>
        new HDWalletProvider(
          privateKey,
          `https://matic-mumbai.chainstacklabs.com`
        ),
      network_id: 80001,
      skipDryRun: true,
      enableTimeouts: false,
      before_timeout: 240000
    },
    matic: {
      provider: () =>
        new HDWalletProvider(
          privateKey,
          `https://matic-mainnet.chainstacklabs.com`
        ),
      network_id: 137,
      confirmations: 2,
      timeoutBlocks: 400
    },
    arbitrumTest: {
      provider: () =>
        new HDWalletProvider(privateKey, `https://rinkeby.arbitrum.io/rpc`),
      network_id: 421611,
      gas: 40000000
    },
    arbitrumTest2: {
      provider: () =>
        new HDWalletProvider(privateKey, `https://kovan5.arbitrum.io/rpc`),
      network_id: "*"
    },

    devSkaleLocalMainnet: {
      provider: () =>
        new HDWalletProvider(
          "0x7ec3bb27ea4718da58251e7f5c2edda830de602ecc30c57efe74fe5c1d798a5b",
          "http://127.0.0.1:8545"
        ),
      network_id: "*",
      gas: 40000000
    },
    devSkaleLocalSideChain: {
      provider: () =>
        new HDWalletProvider(
          "0x7ec3bb27ea4718da58251e7f5c2edda830de602ecc30c57efe74fe5c1d798a5b",
          "http://127.0.0.1:15000"
        ),
      gasPrice: 0,
      gas: 40000000,
      network_id: "*"
    },
    kintsugi: {
      //eth2 merge testnet
      provider: () =>
        new HDWalletProvider(privateKey, "https://rpc.kintsugi.themerge.dev"),
      network_id: "*"
    }
    // Useful for private networks
    // private: {
    // provider: () => new HDWalletProvider(mnemonic, `https://network.io`),
    // network_id: 2111,   // This network is yours, in the cloud.
    // production: true    // Treats this network as if it was a public net. (default: false)
    // }
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.6.10", // Fetch exact version from solc-bin (default: truffle's version)
      docker: false, // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {
        // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 200
        }
        //evmVersion: "byzantium"
      }
    }
  }
};
