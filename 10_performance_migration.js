const ERC20Full = artifacts.require('ERC20Full')
const ERC721Full = artifacts.require('ERC721Full')

const TransactionManagement = artifacts.require("TransactionManagement")
const TokenManagement = artifacts.require("TokenManagement")
const ValidatorInterfaceContract = artifacts.require("ValidatorInterfaceContract")

const ethers = require('ethers')

const fs = require('fs');
const outputPath = '/tmp/tokenDistro.txt'
try {
  fs.unlinkSync(outputPath)
  //file removed
} catch(e) {}

const erc20s = [
	'TKA','TKB','TKC','TKD','TKE','TKF','TKG','TKH','TKI','TKJ',
	'TKK','TKL','TKM','TKN','TKO','TKP','TKQ','TKR','TKS','TKT',
	'TKU','TKV','TKW','TKX','TKY','TKZ','TKA1','TKA2','TKA3','TKA4',
	'TKA5','TKA6','TKA7','TKA8','TKA9','TKB1','TKB2','TKB3','TKB4','TKB5'
]

const erc721s = [
	'NFTA','NFTB','NFTC','NFTD','NFTE','NFTF','NFTG','NFTH','NFTI','NFTJ',
	'NFTK','NFTL','NFTM','NFTN','NFTO','NFTP','NFTQ','NFTR','NFTS','NFTT',
	'NFTU','NFTV','NFTW','NFTX','NFTY','NFTZ','NFTA1','NFTA2','NFTA3','NFTA4',
	'NFTA5','NFTA6','NFTA7','NFTA8','NFTA9','NFTB1','NFTB2','NFTB3','NFTB4','NFTB5'
]

let account = output = instance = instanceTokenManagement = appr = validatorInstance = ''
let balance = Erc1155tokenID = 0

module.exports = function (deployer, network, accounts) {
	deployer.then(async () => {
		  validatorInstance = await ValidatorInterfaceContract.at('0x97ef4a7B0c740e372f1F7D0C2281BdEeBd786e30')
		  let instanceTransactionManagement = await TransactionManagement.at(
		    await validatorInstance.getTransactionManagementAddress()
		  )
		  // Launch an ERC20 and deposit some to instantiate onto Cryptoraves. Then send some to Twitter user L1
		  instanceTokenManagement = await TokenManagement.at(
		    await instanceTransactionManagement.getTokenManagementAddress()
		  )
	})
  //ERC20's
  deployer.then(async () => {
  	
  	for await (token of erc20s){
  		
  		account = ethers.Wallet.createRandom().address
  		amount = getRandomInt(10000) * getRandomInt(10000)

  		await deployer.deploy(ERC20Full, accounts[0], 'Token'+token, token, 18, ethers.utils.parseUnits(amount.toString(),18))
	    instance = await ERC20Full.deployed()
	        
	    balance = await instance.balanceOf(accounts[0])

	    appr = await instance.approve(instanceTokenManagement.address, ethers.utils.parseEther(amount.toString()))
	    Erc1155tokenID = await instanceTokenManagement.deposit(ethers.utils.parseEther(amount.toString()), instance.address, 20, true)
	    Erc1155tokenID = Erc1155tokenID.logs[0]['args']['cryptoravesTokenId'].toString()
	    output = 'Account: '+accounts[0]+' Token: '+token+' Token Address: '+instance.address+' Balance: '+ethers.utils.formatUnits(balance.toString(), 18)+' TokenID: '+Erc1155tokenID+"\n"
	  	await fs.appendFile(outputPath, output, function (err) {
	  		console.log(output)
			if (err) throw err
		})
  	}
  })

  //ERC721's
  deployer.then(async () => {
  	let tokenID = 0
  	for await (token of erc721s){
  		
  		account = ethers.Wallet.createRandom().address
  		
  		await deployer.deploy(ERC721Full, accounts[0], 'Token'+token, token)
	    instance = await ERC721Full.deployed()
	        
	    await instance.mint(accounts[0], 'http:/abc.com')
	    
	    balance = await instance.balanceOf(accounts[0])

	    if ( tokenID == 0){
	    	tokenID=1
	    }else{
	    	tokenID=0
	    }

	    appr = await instance.approve(instanceTokenManagement.address, tokenID)
	    Erc1155tokenID = await instanceTokenManagement.deposit(tokenID, instance.address, 721, true)
	    Erc1155tokenID = Erc1155tokenID.logs[0]['args']['cryptoravesTokenId'].toString()
	    output = 'Account: '+accounts[0]+' Token: '+token+' Token Address: '+instance.address+' Balance: '+balance.toString()+' TokenID: '+Erc1155tokenID+"\n"
	  	await fs.appendFile(outputPath, output, function (err) {
	  		console.log(output)
			if (err) throw err
		})
  	}
  })
  
}


function getRandomInt(max) {
  return Math.floor(Math.random() * Math.floor(max));
}