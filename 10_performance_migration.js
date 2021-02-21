const ERC20Full = artifacts.require('ERC20Full')
const ERC721Full = artifacts.require('ERC721Full')

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

let account = output = ''
let balance = 0

module.exports = function (deployer, network, accounts) {
  
  //ERC20's
  deployer.then(async () => {
  	
  	for await (token of erc20s){
  		
  		account = ethers.Wallet.createRandom().address
  		amount = getRandomInt(10000) * getRandomInt(10000)

  		await deployer.deploy(ERC20Full, account, 'Token'+token, token, 18, ethers.utils.parseUnits(amount.toString(),18))
	    const instance = await ERC20Full.deployed()
	        
	    console.log('\n*************************************************************************\n')
	    console.log('ERC20 Address:',instance.address)
	    console.log('To Account:',account)
	    console.log('Amount:',amount)
	    console.log('\n*************************************************************************\n')

	    output = 'Account: '+account+' Token: '+token+' Amount: '+amount+"\n"
	  	await fs.appendFile(outputPath, output, function (err) {
	  		console.log(output)
			if (err) throw err
		})
  	}
  })

  //ERC721's
  deployer.then(async () => {
  	
  	for await (token of erc721s){
  		
  		account = ethers.Wallet.createRandom().address
  		
  		await deployer.deploy(ERC721Full, accounts[0], 'TokenY', 'TKY')
	    const instance = await ERC721Full.deployed()
	        
	    instance.mint(account, 'abc')
	    
	    console.log('\n*************************************************************************\n')
	    console.log('ERC721 Address:',instance.address)
	    console.log('To Account:',account)
	    console.log('\n*************************************************************************\n')

	    output = 'Account: '+account+' Token: '+token+"\n"
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