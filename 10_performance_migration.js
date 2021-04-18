const ERC20Full = artifacts.require('ERC20Full')
const ERC721Full = artifacts.require('ERC721Full')

const TransactionManagement = artifacts.require("TransactionManagement")
const TokenManagement = artifacts.require("TokenManagement")
const ValidatorInterfaceContract = artifacts.require("ValidatorInterfaceContract")
const CryptoravesToken = artifacts.require("CryptoravesToken")
const UserManagement = artifacts.require("UserManagement")

const ethers = require('ethers')

const fs = require('fs');
const outputPath = '/tmp/tokenDistro.txt'

const homedir = require('os').homedir();
const handlesFile = fs.readFileSync(homedir+"/token-game/lambda-functions/TwitterEndpointV1/test-data/sampleHandles.json")
let handles = JSON.parse(handlesFile)
try {
  fs.unlinkSync(outputPath)
  fs.unlinkSync('/tmp/userPortfolios.json')
  //file removed
} catch(e) {}

const erc20s = [
	'TKA','TKB','TKC','TKD','TKE','TKF','TKG','TKH','TKI','TKJ',
	'TKK','TKL','TKM','TKN','TKO','TKP','TKQ','TKR','TKS','TKT',
	'TKU','TKV','TKW','TKX','TKY','TKZ','TKA1','TKA2','TKA3','TKA4',
	'TKA5','TKA6','TKA7','TKA8','TKA9','TKB1','TKB2','TKB3','TKB4','TKB5',
	'TKB6','TKB7','TKB8','TKB9','TKB10','TKB11','TKB12','TKB13','TKB14','TKB15',
	'TKC1','TKC2','TKC3','TKC4','TKC5','TKC6','TKC7','TKC8','TKC9','TKC10'
]

const erc721s = [
	'NFTA','NFTB','NFTC','NFTD','NFTE','NFTF','NFTG','NFTH','NFTI','NFTJ',
	'NFTK','NFTL','NFTM','NFTN','NFTO','NFTP','NFTQ','NFTR','NFTS','NFTT',
	'NFTU','NFTV','NFTW','NFTX','NFTY','NFTZ','NFTA1','NFTA2','NFTA3','NFTA4',
	'NFTA5','NFTA6','NFTA7','NFTA8','NFTA9','NFTB1','NFTB2','NFTB3','NFTB4','NFTB5',
	'NFTB6','NFTB7','NFTB8','NFTB9','NFTB10','NFTB11','NFTB12','NFTB13','NFTB14','NFTB15',
	'NFTC1','NFTC2','NFTC3','NFTC4','NFTC5','NFTC6','NFTC7','NFTC8','NFTC9','NFTC10'
]

let account = output = instance = instanceTokenManagement = appr = validatorInstance = ''
let balance = Erc1155tokenID = 0
let twitterIds = []
let account0TwitterId = 99434443434
let userPortfolios = {}

module.exports = function (deployer, network, accounts) {
	deployer.then(async () => {

		  validatorInstance = await ValidatorInterfaceContract.deployed()
		  let instanceTransactionManagement = await TransactionManagement.at(
		    await validatorInstance.getTransactionManagementAddress()
		  )
		  // Launch an ERC20 and deposit some to instantiate onto Cryptoraves. Then send some to Twitter user L1
		  instanceTokenManagement = await TokenManagement.at(
		    await instanceTransactionManagement.getTokenManagementAddress()
		  )

		  instanceCryptoravesToken = await CryptoravesToken.at(
		  	await instanceTokenManagement.getCryptoravesTokenAddress()
		  )

		  instanceUserManagement = await UserManagement.at(
		  	await instanceTransactionManagement.getUserManagementAddress()
		  )

		  res = await validatorInstance.validateCommand(
	        [account0TwitterId,0,0,0,0, 1234567890],
	        ['Mr.Garrison', '', '','twitter','mapaccount','https://i.imgur.com/bDNoOA2.jpg',accounts[0]],
	        [],
	        ethers.utils.formatBytes32String('')
	      )
	      
		  
	      userPortfolios[account0TwitterId] = {
	      	"twitterUsername":'Mr.Garrison',
	      	"cryptoravesAddress":'0x'+res.receipt['rawLogs'][0]['topics'][1].substr(26),
	      	"layer1account":accounts[0],
	      	'imageUrl':'https://i.imgur.com/bDNoOA2.jpg',
	      	"balances":{}
	      }
	})
  //ERC20's
  deployer.then(async () => {
  	let counter = 0
  	for await (token of erc20s){
  		//Mint
  		account = ethers.Wallet.createRandom().address
  		amount = 1000000000

  		await deployer.deploy(ERC20Full, accounts[0], 'Token'+token, token, 18, ethers.utils.parseUnits(amount.toString(),18))
	    instance = await ERC20Full.deployed()
	        
	    

	    appr = await instance.approve(instanceTokenManagement.address, ethers.utils.parseEther(amount.toString()))
	    Erc1155tokenID = await instanceTokenManagement.deposit(ethers.utils.parseEther(amount.toString()), instance.address, 20, true)
	    Erc1155tokenID = Erc1155tokenID.logs[1]['args']['cryptoravesTokenId'].toString()

	    if(Erc1155tokenID==0){
	    	Erc1155tokenID='1000000000000000000000000000000000001'
	    }

	    	  	
		//transfer
		randomTwitterId = (getRandomInt(100000) * getRandomInt(100000) + 99000000000).toString()
		twitterIds.push(randomTwitterId.toString())
		twitterUsername = 'rando'+counter
		//amount = getRandomInt(1000) * getRandomInt(1000)
		res = await validatorInstance.validateCommand(
			[account0TwitterId,randomTwitterId,0,(amount/100),getRandomInt(3), counter+1000000],
			['Mr.Garrison', twitterUsername, token,'twitter','transfer','',''],
			[ethers.utils.formatBytes32String('')],
			ethers.utils.formatBytes32String('')
		)
		balance = await instanceCryptoravesToken.balanceOf(userPortfolios[account0TwitterId]['cryptoravesAddress'] , Erc1155tokenID)
	    output = 'Account: '+accounts[0]+' Token: '+token+' Token Address: '+instance.address+' Balance: '+ethers.utils.formatUnits(balance.toString(), 18)+' CryptoravesTokenID: '+Erc1155tokenID+"\n"
	  	await fs.appendFile(outputPath, output, function (err) {
	  		console.log(output)
			if (err) throw err
		})
		
		//console.log(res.receipt.rawLogs)
		userPortfolios[account0TwitterId]['balances'][Erc1155tokenID]={
	  		'ticker':token,
	  		'tokenAddress':instance.address,
	  		'balance':ethers.utils.formatUnits(balance.toString(), 18)
	  	}
	  	
		userPortfolios[randomTwitterId.toString()] = {
			"twitterUsername":twitterUsername,
			"cryptoravesAddress": '0x'+res.receipt['rawLogs'][0]['topics'][1].substr(26),
			"layer1account":"",
			"balances":{}
		}
		balance = await instanceCryptoravesToken.balanceOf(userPortfolios[randomTwitterId]['cryptoravesAddress'],Erc1155tokenID)
		userPortfolios[randomTwitterId]['balances'][Erc1155tokenID]={
			'ticker':token,
	  		'tokenAddress':instance.address,
	  		'balance':ethers.utils.formatUnits(balance.toString(), 18)
		}


		//set emoji

		if (Erc1155tokenID != '1000000000000000000000000000000000001'){
			await instanceTokenManagement.setEmoji(Erc1155tokenID, '😑')
		}
		
		//console.log(userPortfolios[randomTwitterId])
		counter++
  	}

  	/*
  	//transfer
  	let tknAddress = await instanceTokenManagement.getAddressBySymbol('TKB5')
	let tokenID = await instanceTokenManagement.getManagedTokenIdByAddress(tknAddress)
	console.log('Token ID:',tokenID.toString())
	console.log('Token ID:',Erc1155tokenID)
	let layer2account = await instanceUserManagement.getLayerTwoAccount(accounts[0])
	balance = await instanceCryptoravesToken.balanceOf(layer2account, Erc1155tokenID)
	console.log('Balance: ', balance.toString())
	*/

  })



  //ERC721's
  deployer.then(async () => {
  	let tokenID = 0
  	let counter = 0
  	for await (token of erc721s){
  		
  		//mint
  		account = ethers.Wallet.createRandom().address
  		
  		await deployer.deploy(ERC721Full, accounts[0], 'Token'+token, token)
	    instance = await ERC721Full.deployed()
	        
	    await instance.mint(accounts[0], 'http:/abc.com')

	    if ( tokenID == 0){
	    	tokenID=1
	    }else{
	    	tokenID=0
	    }
	    appr = await instance.approve(instanceTokenManagement.address, tokenID)
	    Erc1155tokenID = await instanceTokenManagement.deposit(tokenID, instance.address, 721, true)
	    Erc1155tokenID = Erc1155tokenID.logs[1]['args']['cryptoravesTokenId'].toString()
		balance = await instanceCryptoravesToken.balanceOf(userPortfolios[account0TwitterId]['cryptoravesAddress'] , Erc1155tokenID)
	    output = 'Account: '+accounts[0]+' Token: '+token+' Token Address: '+instance.address+' Balance: '+balance.toString()+' CryptoravesTokenID: '+Erc1155tokenID+"\n"
	    await fs.appendFile(outputPath, output, function (err) {
	  		console.log(output)
			if (err) throw err
		})
	    
	  	

	  	if(token != 'NFTC10'){ //reserve NFTC10 for lambda_handler testing
		  	res = await validatorInstance.validateCommand(
				[account0TwitterId,twitterIds[counter],0,tokenID,0, counter+100],
				['Mr.Garrison', handles[counter], token,'twitter','transfer','https://i.picsum.photos/id/333/200/200.jpg',''],
				[ethers.utils.formatBytes32String('')],
				ethers.utils.formatBytes32String('')
			)
			//console.log(res)
		}

		balance = await instanceCryptoravesToken.balanceOf(userPortfolios[twitterIds[counter]]['cryptoravesAddress'], Erc1155tokenID)

		userPortfolios[twitterIds[counter]]['balances'][Erc1155tokenID.toString()] = {
			'ticker':token,
			'tokenId':tokenID,
	  		'tokenAddress':instance.address,
	  		'balance':balance.toString(),
	  		'tokenId':tokenID
		}

		if ( tokenID == 0){
	    	tokenID=1
	    }else{
	    	tokenID=0
	    }
	    appr = await instance.approve(instanceTokenManagement.address, tokenID)
	    Erc1155tokenID = await instanceTokenManagement.deposit(tokenID, instance.address, 721, true)
	    Erc1155tokenID = Erc1155tokenID.logs[0]['args']['cryptoravesTokenId'].toString()
		balance = await instanceCryptoravesToken.balanceOf(userPortfolios[account0TwitterId]['cryptoravesAddress'] , Erc1155tokenID)
	    output = 'Account: '+accounts[0]+' Token: '+token+' Token Address: '+instance.address+' Balance: '+balance.toString()+' CryptoravesTokenID: '+Erc1155tokenID+"\n"
	    await fs.appendFile(outputPath, output, function (err) {
	  		console.log(output)
			if (err) throw err
		})

		userPortfolios[account0TwitterId]['balances'][Erc1155tokenID]={
	  		'ticker':token,
	  		'tokenId':tokenID,
	  		'CryptoravesTokenID':Erc1155tokenID,
	  		'tokenAddress':instance.address,
	  		'balance':balance.toString()
		}
	  	
		//set emoji
		await instanceTokenManagement.setEmoji(Erc1155tokenID, '💫')
		//console.log(res.receipt.rawLogs)
		//console.log(userPortfolios[twitterIds[counter]])
		
	

		counter++
  	}
  })


  //mapaccounts
  deployer.then(async () => {
  	let counter = 0
  	for await (userName of handles){

  		let url = "https://sample-imgs.s3.amazonaws.com/"+userName+".png"
	  	let res = await validatorInstance.validateCommand(
			[twitterIds[counter],0,0,0,0,counter+1000],
			[userName, '', '', 'twitter','mapaccount',url,accounts[counter+1]],
			[],
			ethers.utils.formatBytes32String('')
  		)
  		//console.log(res)
  		//console.log(res.receipt.rawLogs)
  		userPortfolios[twitterIds[counter]]['twitterUsername'] = userName
  		userPortfolios[twitterIds[counter]]['layer1account'] = accounts[counter+1]
  		userPortfolios[twitterIds[counter]]['imageUrl'] = url
  		

  		//withdrawals 
  		for (tokenProfile in userPortfolios[twitterIds[counter]]['balances']){
			if (userPortfolios[twitterIds[counter]]['balances'][tokenProfile]['ticker'].startsWith('NFT')){
				//withdraw ERC721
				
				let _tokenID = userPortfolios[twitterIds[counter]]['balances'][tokenProfile]['tokenId']
				let _addr = userPortfolios[twitterIds[counter]]['balances'][tokenProfile]['tokenAddress']
				if ( counter < 59 && counter % 3 == 0){
					console.log('Withdraw NFT:', _tokenID, _addr)
					let res = await instanceTokenManagement.withdrawERC721(_tokenID, _addr, true, {from:accounts[counter+1]})
				}
				//console.log(res)
			}else{
				//withdraw ERC20
				let _amount  = 10
				let _addr = userPortfolios[twitterIds[counter]]['balances'][tokenProfile]['tokenAddress']
				console.log('Withdraw ERC20:', _amount, _addr)
				let res = await instanceTokenManagement.withdrawERC20(_amount, _addr, true, {from:accounts[counter+1]})
				//console.log(res)
				
			}
		}
		counter++

  	}
  	let data = await JSON.stringify(userPortfolios)
	await fs.appendFile('/tmp/userPortfolios.json', data, (err) => {
		
	    if (err) {
			console.log(err);
	    }else {
		    console.log('Data written to file');
		}
	})
  	
  })
  
	
}


function getRandomInt(max) {
  return Math.floor(Math.random() * Math.floor(max));
}