const ERC20Full = artifacts.require('ERC20Full')
const ERC721Full = artifacts.require('ERC721Full')

const TransactionManagement = artifacts.require("TransactionManagement")
const TokenManagement = artifacts.require("TokenManagement")
const ValidatorInterfaceContract = artifacts.require("ValidatorInterfaceContract")
const CryptoravesToken = artifacts.require("CryptoravesToken")
const UserManagement = artifacts.require("UserManagement")

const ethers = require('ethers')

const fs = require('fs');
const readline = require('readline');

var res = ''
var dataFile = ''
var modLine = ''
const homedir = require('os').homedir();
try{
	dataFile = homedir+"/token-game/lambda-functions/TwitterEndpointV1/test-data/realUserData.json"
}catch(e){
	console.log(e)
	console.log('realUserData.json file not found. Be sure token-game is cloned in your HOME dir')
}

module.exports = function (deployer, network, accounts) {
  deployer.then(async () => {

		  validatorInstance = await ValidatorInterfaceContract.deployed()
		  let instanceTransactionManagement = await TransactionManagement.at(
		    await validatorInstance.transactionManagerAddress()
		  )
		  // Launch an ERC20 and deposit some to instantiate onto Cryptoraves. Then send some to Twitter user L1
		  instanceTokenManagement = await TokenManagement.at(
		    await instanceTransactionManagement.getTokenManagementAddress()
		  )

		  instanceCryptoravesToken = await CryptoravesToken.at(
		  	await instanceTokenManagement.cryptoravesTokenAddr()
		  )

		  instanceUserManagement = await UserManagement.at(
		  	await instanceTransactionManagement.getUserManagementAddress()
		  )
			const fileStream = fs.createReadStream(dataFile);
			const rl = readline.createInterface({
		    input: fileStream,
		    crlfDelay: Infinity
		  })

			//cryptoraves account must me admin
			//res = await validatorInstance.validateCommand(
			//	 [1054910011795824640,0,0,0,0, 1234567890],
			//	 ['cryptoraves', '', '','twitter','mapaccount','https://pbs.twimg.com/profile_images/1072214331113304065/mtDZkmFc_400x400.jpg',accounts[0]]
			// )
			let mappedAccounts=[]
			let counter=0

			const outputPath = '/tmp/'+deployer.network+'-tokenDredeployErrorsistro.txt'
		  try {
		    fs.unlinkSync(outputPath)
		  } catch(e) {}

			for await (const line of rl) {
		    record = JSON.parse(line)
				let isExport = false
				if(record['twitterIdFrom']=='LAUNCH' || record['twitterIdFrom']=='IMPORT'){
					record['twitterIdFrom']=record['twitterIdTo']
					record['twitterHandleFrom']=record['twitterHandleTo']
				}
				if(!record['tweetId']){
					record['tweetId']=1234567
				}
				if(record['twitterIdTo']=='EXPORT'){
					isExport = true
				}
				if(!record['twitterIdThirdParty']){
					record['twitterIdThirdParty']=0
				}
				if (record['L1Address'] && !mappedAccounts.includes(record['L1Address'])) {
					//map account
					try{
						res = await validatorInstance.validateCommand(
				    	[record['twitterIdFrom'],record['twitterIdTo'],record['twitterIdThirdParty'],0,record['decimalPlaceLocation'], record['tweetId']],
				    	[record['twitterHandleFrom'], record['twitterHandleTo'], record['ticker'],record['_platformName'],'mapaccount',record['_fromImgUrl'],record['L1Address']]
				    )
					}catch(e){
						await fs.appendFile(outputPath, e.toString()+JSON.stringify(record)+"\r\n", function (err) {
							console.log(record)
							console.log(e)
						})
					}

					mappedAccounts.push(record['L1Address'])
				}



				if(!isExport){
					try{
						res = await validatorInstance.validateCommand(
				    	[record['twitterIdFrom'],record['twitterIdTo'],record['twitterIdThirdParty'],parseInt(record['amountOrId']),record['decimalPlaceLocation'], record['tweetId']],
				    	[record['twitterHandleFrom'], record['twitterHandleTo'], record['ticker'],record['_platformName'],record['_txnType'],record['_fromImgUrl'],record['L1Address']]
				    )
					}catch(e){
						await fs.appendFile(outputPath, e.toString()+JSON.stringify(record)+"\r\n", function (err) {
							console.log(record)
							console.log(e)
						})
					}
					console.log(res)
					console.log(counter)
				}

				counter++


		  }
			console.log('here')
			fs.close()
			console.log('here2')
	})
}
