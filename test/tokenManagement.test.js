const TokenManagement = artifacts.require("TokenManagement");
const CryptoravesToken = artifacts.require("CryptoravesToken");

const ERC20Full = artifacts.require('ERC20Full')
const ERC721Full = artifacts.require('ERC721Full')

const ethers = require('ethers')

let primary_tokenId1155 = 12345

let emoji = '🤯'

var startTime, endTime

contract("TokenManagement", async accounts => {
  it("barebones send eth test", async () => {
      const params = {
          from: accounts[0],
          to: ethers.Wallet.createRandom().address,
          value: 1
      };
      
      let balance1 = await web3.eth.getBalance(accounts[0])
      
      balance1 =parseInt(balance1.substr(-5))
      //start()
      await web3.eth.sendTransaction(params)
      //end()
      let balance2 = await web3.eth.getBalance(accounts[0])
      balance2 =parseInt(balance2.substr(-5))

      assert.equal(
        balance1,
        balance2 + 1,
        "ETH balances not equal"
      )
  })
  it("Drop 1 billion to admin", async () => {
    let instanceTokenManagement = await TokenManagement.deployed()
    let instanceCryptoravesToken = await CryptoravesToken.at(
      await instanceTokenManagement.getCryptoravesTokenAddress()
    )
    
    let amount = ethers.utils.parseUnits('1000000000',18).toString()

    res = await instanceTokenManagement.dropCrypto(
      'fakeUser1',
      accounts[0],
      amount,
      amount,
      ethers.utils.formatBytes32String('test')
    )
    
    primary_tokenId1155 = await instanceTokenManagement.getManagedTokenIdByAddress(accounts[0])
    let balance = await instanceCryptoravesToken.balanceOf(accounts[0], primary_tokenId1155)

    assert.equal(
      balance.toString(),
      amount,
      'ERC1155 mint failed'
    )
  })
  it("deposits ETH", async () => {
  	let instanceTokenManagement = await TokenManagement.deployed()

  	let zeroAddr = '0x0000000000000000000000000000000000000000'
  	let ethAmt = '1.14'
  	let formatttedWeiAmt = ethers.utils.parseEther(ethAmt).toString()

  	let initialEthBalance = await web3.eth.getBalance(accounts[0]);
	let initialFormattedBal = ethers.utils.formatEther(
		initialEthBalance
	).toString()

    let res = await instanceTokenManagement.deposit(
    	formatttedWeiAmt, 
    	zeroAddr,
      20, //indicates ERC20
      false,
    	{
    		from: accounts[0],
    		value: formatttedWeiAmt
    	}
    )

    let gasUsed = res.receipt.cumulativeGasUsed
    let tokenId1155 = await instanceTokenManagement.getManagedTokenIdByAddress(zeroAddr)
    let instanceCryptoravesToken = await CryptoravesToken.at(
      await instanceTokenManagement.getCryptoravesTokenAddress()
    )
    let balance = await instanceCryptoravesToken.balanceOf(accounts[0], tokenId1155)

    let finalEthBalance = await web3.eth.getBalance(accounts[0]);
	let finalFormattedBal = ethers.utils.formatEther(
		finalEthBalance
	).toString()

    assert.equal(
    	balance.toString(),
    	formatttedWeiAmt, 
    	'ETH amount does not match 1155 balance after deposit'
    )

    const txInfo = await web3.eth.getTransaction(res.tx); 
	const gasCost = txInfo.gasPrice * res.receipt.gasUsed
    
  
	let totalFinalBalance = (finalEthBalance * 1) + (formatttedWeiAmt * 1) + gasCost
	assert.equal(
		Number.parseFloat(initialEthBalance.toString()).toPrecision(14),
    	Number.parseFloat(totalFinalBalance.toString()).toPrecision(14),
		'initial ETH balance doesn\'t match final ETH balance + gas spent'
	)

  })
  it("withdraws ETH", async () => {
  	let instanceTokenManagement = await TokenManagement.deployed()
    let zeroAddr = '0x0000000000000000000000000000000000000000'
  	let ethAmt = '1.14'
  	let formatttedWeiAmt = ethers.utils.parseEther(ethAmt).toString()

  	let initialEthBalance = await web3.eth.getBalance(accounts[0]);

    let res = await instanceTokenManagement.withdrawERC20(
    	formatttedWeiAmt, 
    	zeroAddr
    )
    const txInfo = await web3.eth.getTransaction(res.tx); 
	const gasCost = txInfo.gasPrice * res.receipt.gasUsed
    
    let tokenId1155 = await instanceTokenManagement.getManagedTokenIdByAddress(zeroAddr)
    let instanceCryptoravesToken = await CryptoravesToken.at(
      await instanceTokenManagement.getCryptoravesTokenAddress()
    )
    let balance = await instanceCryptoravesToken.balanceOf(accounts[0], tokenId1155)
    
    let finalEthBalance = await web3.eth.getBalance(accounts[0]);
	
    let totalFinalBalance = (initialEthBalance * 1) + (formatttedWeiAmt * 1) - gasCost
	
    assert.equal(
    	Number.parseFloat(finalEthBalance.toString()).toPrecision(14),
    	Number.parseFloat(totalFinalBalance.toString()).toPrecision(14),
    	'ETH balance does not match after withdrawal'
    )
  })
  it("deposits ERC20", async () => {
  	let instanceTokenManagement = await TokenManagement.deployed()
    let erc20Instance = await ERC20Full.deployed()	
    let appr = await erc20Instance.approve(
    	instanceTokenManagement.address,
    	ethers.utils.parseUnits('987654321',18)
    )
    await instanceTokenManagement.deposit(
    	ethers.utils.parseUnits('987654321',18), 
    	erc20Instance.address,
      20, //indicates ERC20
      false
    )
    let tokenId1155 = await instanceTokenManagement.getManagedTokenIdByAddress(erc20Instance.address)

    let instanceCryptoravesToken = await CryptoravesToken.at(
      await instanceTokenManagement.getCryptoravesTokenAddress()
    )
    let balance = await instanceCryptoravesToken.balanceOf(accounts[0], tokenId1155)
    assert.equal(
    	balance.toString(),
    	ethers.utils.parseUnits('987654321',18).toString(),
    	'ERC20 balance does not match after deposit'
    )
  })

  it("checks symbol & emoji lookup", async () => {
      let instanceTokenManagement = await TokenManagement.deployed()
      let erc20Instance = await ERC20Full.deployed()
      
      let addressB1 = await instanceTokenManagement.getAddressBySymbol('TKX')
      let tokenId1155_B = await instanceTokenManagement.getManagedTokenIdByAddress(
        addressB1
      )
      
      let addressB3 = await instanceTokenManagement.getAddressBySymbol('TKX')
      let addressB4 = await instanceTokenManagement.getAddressBySymbol('KAJDHAKJ')
      
      //change ticker and emoji
      await instanceTokenManagement.setEmoji(tokenId1155_B, '💫')
      let _sym1 = await instanceTokenManagement.getSymbol(tokenId1155_B)
      let _emoj1 = await instanceTokenManagement.getEmoji(tokenId1155_B)
      assert.isOk(
        _sym1 == 'TKX',
       _emoj1 == '💫',
        'get/set emoji and/or symbol failed'
      )
      let addressB2 = await instanceTokenManagement.getAddressBySymbol('💫')
      
      assert.isOk(
        addressB1 == addressB2 && erc20Instance.address == addressB1,
        addressB2 == addressB3 && addressB2 != addressB4,
        'emoji & symbol address lookup failed'
      )
  })
  it("withdraws ERC20", async () => {
  	let instanceTokenManagement = await TokenManagement.deployed()
    let erc20Instance = await ERC20Full.deployed()	

    await instanceTokenManagement.withdrawERC20(
    	ethers.utils.parseUnits('87654321',18), 
    	erc20Instance.address
    )
    let tokenId1155 = await instanceTokenManagement.getManagedTokenIdByAddress(erc20Instance.address)
    let instanceCryptoravesToken = await CryptoravesToken.at(
      await instanceTokenManagement.getCryptoravesTokenAddress()
    )
    let balance = await instanceCryptoravesToken.balanceOf(accounts[0], tokenId1155)
    assert.equal(
    	balance.toString(),
    	ethers.utils.parseUnits('900000000',18).toString(),
    	'ERC20 balance does not match after withdrawal'
    )
  })
  it("deposits ERC721", async () => {
  	let instanceTokenManagement = await TokenManagement.deployed()
    let erc721Instance = await ERC721Full.deployed()
    let erc721Id=0

    let b1 = await erc721Instance.balanceOf(accounts[0])
    
    let appr = await erc721Instance.approve(
      instanceTokenManagement.address,
      erc721Id
    )
    //console.log(await erc721Instance.safeTransferFrom(accounts[0], instanceTokenManagement.address, 0))
    console.log('herex')

    await instanceTokenManagement.deposit(
    	erc721Id,
    	erc721Instance.address,
      721, //indicates ERC721
      false
    )
    console.log('here2')
    let tokenId1155 = await instanceTokenManagement.getManagedTokenIdByAddress(erc721Instance.address)
    let instanceCryptoravesToken = await CryptoravesToken.at(
      await instanceTokenManagement.getCryptoravesTokenAddress()
    )
    let balance = await instanceCryptoravesToken.balanceOf(accounts[0], tokenId1155)
    assert.equal(
    	balance.toString(),
    	1,
    	'ERC721 balance does not match after deposit'
    )
  })
  it("withdraws ERC721", async () => {
  	let instanceTokenManagement = await TokenManagement.deployed()
    let erc721Instance = await ERC721Full.deployed()
    let tokenId1155 = await instanceTokenManagement.getManagedTokenIdByAddress(erc721Instance.address)
    let instanceCryptoravesToken = await CryptoravesToken.at(
      await instanceTokenManagement.getCryptoravesTokenAddress()
    )
    let balance1 = await instanceCryptoravesToken.balanceOf(accounts[0], tokenId1155)
    

    await instanceTokenManagement.withdrawERC721(
    	0,
    	erc721Instance.address
    )
    
    let balance2 = await erc721Instance.balanceOf(accounts[0])
    assert.equal(
    	balance1.toString(),
    	balance2.toString(),
    	'ERC721 balance does not match after deposit'
    )
  })
  it("checks symbols of ERC20/721", async () => {
    let tokenManagementInstance = await TokenManagement.deployed()
    let erc721Instance = await ERC721Full.deployed()
    let erc20Instance = await ERC20Full.deployed()

    let symbol = await tokenManagementInstance.getSymbol(
      await tokenManagementInstance.getManagedTokenIdByAddress(erc20Instance.address)
    )
    assert.equal(
      symbol,
      'TKX',
      'ERC20 symbol does not match'
    )
    symbol = await tokenManagementInstance.getSymbol(
      await tokenManagementInstance.getManagedTokenIdByAddress(erc721Instance.address)
    )
    assert.equal(
      symbol,
      'TKY',
      'ERC721 symbol does not match'
    )
  })
  it("set and get emoji for a token", async () => {
    let tokenManagementInstance = await TokenManagement.deployed()
    let erc721Instance = await ERC721Full.deployed()
    let erc20Instance = await ERC20Full.deployed()
    
    let tokenId = await tokenManagementInstance.getManagedTokenIdByAddress(erc20Instance.address) 
    await tokenManagementInstance.setEmoji(
      tokenId,
      emoji
    )
    let res = await tokenManagementInstance.getEmoji(
      tokenId
    )
    assert.equal(
      emoji,
      res,
      'emoji scheme issue. Result doesn\'t match'
    )
  })
  it("set new uri", async () => {
    let tokenManagementInstance = await TokenManagement.deployed()
    let instanceCryptoravesToken = await CryptoravesToken.at(
      await tokenManagementInstance.getCryptoravesTokenAddress()
    )

    let newUri = 'data:application/json;charset=utf-8;base64,ew0KCSJuYW1lIjogIkFzc2V0IE5hbWUiLA0KCSJkZXNjcmlwdGlvbiI6ICJMb3JlbSBpcHN1bS4uLiIsDQoJImltYWdlIjogImh0dHBzOi8vczMuYW1hem9uYXdzLmNvbS95b3VyLWJ1Y2tldC9pbWFnZXMve2lkfS5wbmciLA0KCSJwcm9wZXJ0aWVzIjogew0KCQkic2ltcGxlX3Byb3BlcnR5IjogImV4YW1wbGUgdmFsdWUiLA0KCQkicmljaF9wcm9wZXJ0eSI6IHsNCgkJCSJuYW1lIjogIk5hbWUiLA0KCQkJInZhbHVlIjogIjEyMyIsDQoJCQkiZGlzcGxheV92YWx1ZSI6ICIxMjMgRXhhbXBsZSBWYWx1ZSIsDQoJCQkiY2xhc3MiOiAiZW1waGFzaXMiLA0KCQkJImNzcyI6IHsNCgkJCQkiY29sb3IiOiAiI2ZmZmZmZiIsDQoJCQkJImZvbnQtd2VpZ2h0IjogImJvbGQiLA0KCQkJCSJ0ZXh0LWRlY29yYXRpb24iOiAidW5kZXJsaW5lIg0KCQkJfQ0KCQl9LA0KCQkiYXJyYXlfcHJvcGVydHkiOiB7DQoJCQkibmFtZSI6ICJOYW1lIiwNCgkJCSJ2YWx1ZSI6IFsxLDIsMyw0XSwNCgkJCSJjbGFzcyI6ICJlbXBoYXNpcyINCgkJfQ0KCX0NCn0='
    await instanceCryptoravesToken.setUri(newUri)
    let uri = await instanceCryptoravesToken.uri(0)
    assert.equal(
      uri,
      newUri,
      'uri matching issue'
    )
  })
  it("checks if both ERC20/721 token addresses are managed by contract", async () => {
  	let instanceTokenManagement = await TokenManagement.deployed()
  	let erc721Instance = await ERC721Full.deployed()
  	let erc20Instance = await ERC20Full.deployed()

  	assert.isOk(await instanceTokenManagement.isManagedToken(erc721Instance.address))
  	assert.isOk(await instanceTokenManagement.isManagedToken(erc20Instance.address))
  })
  it("get totalSupply() of ERC20 & 721", async() => {
      let instanceTokenManagement = await TokenManagement.deployed()
      let erc20Instance = await ERC20Full.deployed()
      let erc721Instance = await ERC721Full.deployed()

      let tokenId1155 = await instanceTokenManagement.getManagedTokenIdByAddress(erc20Instance.address)
      let erc1155TotSupply = await instanceTokenManagement.getTotalSupply(tokenId1155)
      let erc20TotSupply = await erc20Instance.totalSupply()
      assert.equal(
        erc1155TotSupply.toString(),
        erc20TotSupply.toString(),
        "ERC20 Total supply doesn't match"
      )
      tokenId1155 = await instanceTokenManagement.getManagedTokenIdByAddress(erc721Instance.address)
      erc1155TotSupply = await instanceTokenManagement.getTotalSupply(tokenId1155)
      let erc721TotSupply = await erc721Instance.totalSupply()
      assert.equal(
        erc1155TotSupply.toString(),
        erc721TotSupply.toString(),
        "ERC721 Total supply doesn't match"
      )

  })
  it("get managed token id by address", async () => {
  	let instanceTokenManagement = await TokenManagement.deployed()
  	let erc721Instance = await ERC721Full.deployed()
  	let erc20Instance = await ERC20Full.deployed()

  	let id20 = await instanceTokenManagement.getManagedTokenIdByAddress(erc20Instance.address)
  	let id721 = await instanceTokenManagement.getManagedTokenIdByAddress(erc721Instance.address)

  	assert.equal(
  		id20.toString(),
  		'680564733841876926926749214863536422912', //2 << 128
  		"ERC20 token id lookup failed"
  	)
  	assert.equal(
  		id721.toString(),
  		'1020847100762815390390123822295304634368', //3 << 128
  		"ERC721 token id lookup failed"
  	)
  })
  it("add managed token to list", async () => {
  	let instanceTokenManagement = await TokenManagement.deployed()
    //let wallet = ethers.Wallet.createRandom()
  	let id7 = await instanceTokenManagement.getManagedTokenIdByAddress(accounts[0])
  	assert.equal(
  		id7.toNumber(),
  		primary_tokenId1155,
  		"Managed token addition failed"
  	)
  })
  it("token list length ok", async () => {
  	let instanceTokenManagement = await TokenManagement.deployed()
  	let count = await instanceTokenManagement.getTokenListCount()
  	assert.isNumber(
  		count.toNumber(),
  		"Managed token count failed isNumber test"
  	)
  	assert.isOk(
  		count.toNumber(),
  		"Managed token count failed > 0 test"
  	)
  })

  it("check emojis and symbol reverse-lookup", async () => {
    let instanceTokenManagement = await TokenManagement.deployed()

    let res = await instanceTokenManagement.symbolAndEmojiLookupTable('TKX')
    assert.equal(
      res.toString(),
      '680564733841876926926749214863536422912', //2 << 128
      'ERC20 symbol reverse lookup failed'
    )
    assert.equal(
      await instanceTokenManagement.symbolAndEmojiLookupTable('TKY'),
      '1020847100762815390390123822295304634368', //3 << 128
      'ERC721 symbol reverse lookup failed'
    )
    assert.equal(
      await instanceTokenManagement.symbolAndEmojiLookupTable('ETH'),
      '0',
      'ETH symbol reverse lookup failed'
    )
    res = await instanceTokenManagement.symbolAndEmojiLookupTable(emoji)
    assert.equal(
      res.toString(),
      '680564733841876926926749214863536422912', //2 << 128
      'ERC20 Emoji reverse lookup failed'
    )
  })
  it("check decimal handling", async () => {
    let instanceTokenManagement = await TokenManagement.deployed()
    let tokenId1 = await instanceTokenManagement.symbolAndEmojiLookupTable('TKX')
    let tokenId2 = await instanceTokenManagement.symbolAndEmojiLookupTable('TKY')
    assert.equal(
      await instanceTokenManagement.adjustValueByUnits(tokenId1, 1234567, 3),
      1234567000000000000000,
      'erc20 decimal adjustment didn\'t work'
    )
    let res = await instanceTokenManagement.adjustValueByUnits(tokenId2, 2, 0)
    assert.equal(
      res.toString(),
      2,
      'nft decimal adjustment didn\'t work'
    )

    let bn = await instanceTokenManagement.adjustValueByUnits(primary_tokenId1155, 2321, 2)
    assert.equal(
      await instanceTokenManagement.adjustValueByUnits(primary_tokenId1155, 2321, 2),
      23210000000000000000,
      '1155 decimal adjustment failure'
    )
  })
})  


function start() {
  startTime = new Date();
};

function end() {
  endTime = new Date();
  var timeDiff = endTime - startTime; //in ms


  // get seconds 
  var milliseconds = Math.round(timeDiff);
  console.log(milliseconds + " milliseconds");
}