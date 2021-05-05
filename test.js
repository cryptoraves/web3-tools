const fs = require('fs');
const userPortfoliosFile = fs.readFileSync('/tmp/userPortfolios.json')
let userPortfolios = JSON.parse(userPortfoliosFile)

for (portfolio in userPortfolios){
	for (tokenProfile in userPortfolios[portfolio]['balances']){
		if (userPortfolios[portfolio]['balances'][tokenProfile]['ticker'].startsWith('NFT')){
			
		}else{
			console.log(userPortfolios[portfolio]['balances'][tokenProfile])
		}
	}
}
