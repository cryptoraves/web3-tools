const TokenManagement = artifacts.require("TokenManagement");
const CryptoravesToken = artifacts.require("CryptoravesToken");

const ERC20Full = artifacts.require('ERC20Full')
const ERC721Full = artifacts.require('ERC721Full')

const ethers = require('ethers')

let primary_tokenId1155 = 12345

contract("TokenManagement", async accounts => {
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
    
    /*console.log(res)
	console.log('initial bal: ', initialEthBalance)
	console.log('final bal: ', finalEthBalance)
	console.log('final bal + deposit amt: ', (finalEthBalance * 1) + (formatttedWeiAmt * 1) )
	console.log('Gas used in gwei: ', gasUsed)
	console.log('Gas used in wei: ', gasUsed * 20000000000)
	console.log('final bal + deposit amt + gas used x 2: ', (finalEthBalance * 1) + (formatttedWeiAmt * 1) + (gasUsed * 20000000000))
	*/
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
	/*console.log('initial bal: ', initialEthBalance)
	console.log('final bal: ', finalEthBalance)
	console.log('init bal + withdrawal amt: ', (initialEthBalance * 1) + (formatttedWeiAmt * 1) )
	console.log('Gas used in gwei: ', gasCost)
	console.log('Gas used in wei: ', gasCost)
	console.log('init bal + withdrawal amt + gas used x 2: ', (initialEthBalance * 1) + (formatttedWeiAmt * 1) - gasCost)
	*/
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
    let appr = await erc721Instance.approve(
    	instanceTokenManagement.address,
    	0
    )
    await instanceTokenManagement.deposit(
    	0,
    	erc721Instance.address,
      721, //indicates ERC721
      false
    )
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
    let emoji = '🤯'
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
  		2,
  		"ERC20 token id lookup failed"
  	)
  	assert.equal(
  		id721.toString(),
  		3,
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

})  
