const TokenManagement = artifacts.require("TokenManagement");
const CryptoravesToken = artifacts.require("CryptoravesToken");

const ERC20Full = artifacts.require('ERC20Full')
const ERC721Full = artifacts.require('ERC721Full')

const ethers = require('ethers')

let primary_tokenId1155 = 12345
let ids = [11111,22222,33333,44444,55555]
let amounts = [1000,2000,3000,4000,5000]


contract("TokenManagement", async accounts => {
  it("Drop 1 billion to admin", async () => {
    let instanceCryptoravesToken = await CryptoravesToken.deployed()
    let instanceTokenManagement = await TokenManagement.deployed()
    
    let amount = ethers.utils.parseUnits('1000000000',18).toString()

    res = await instanceTokenManagement.dropCrypto(
      accounts[0],
      amount,
      amount,
      ethers.utils.formatBytes32String('test')
    )
    primary_tokenId1155 = await instanceTokenManagement.getManagedTokenIdByAddress(accounts[0])
    let balance = await instanceCryptoravesToken.balanceOf(accounts[0], primary_tokenId1155)
    console.log(accounts[0])
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

    let res = await instanceTokenManagement.depositERC20(
    	formatttedWeiAmt, 
    	zeroAddr,
    	{
    		from: accounts[0],
    		value: formatttedWeiAmt
    	}
    )

    let gasUsed = res.receipt.cumulativeGasUsed
    let tokenId1155 = await instanceTokenManagement.getManagedTokenIdByAddress(zeroAddr)
    let balance = await instance.balanceOf(accounts[0], tokenId1155)

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
    let balance = await instance.balanceOf(accounts[0], tokenId1155)
    
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
    await instanceTokenManagement.depositERC20(
    	ethers.utils.parseUnits('987654321',18), 
    	erc20Instance.address
    )
    let tokenId1155 = await instanceTokenManagement.getManagedTokenIdByAddress(erc20Instance.address)
    let balance = await instance.balanceOf(accounts[0], tokenId1155)
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
    let balance = await instance.balanceOf(accounts[0], tokenId1155)
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
    await instanceTokenManagement.depositERC721(
    	0,
    	erc721Instance.address
    )
    let tokenId1155 = await instanceTokenManagement.getManagedTokenIdByAddress(erc721Instance.address)
    let balance = await instance.balanceOf(accounts[0], tokenId1155)
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
    let balance1 = await instance.balanceOf(accounts[0], tokenId1155)

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
  it("checks if both ERC20/721 token addresses are managed by contract", async () => {
  	let instanceTokenManagement = await TokenManagement.deployed()
  	let erc721Instance = await ERC721Full.deployed()
  	let erc20Instance = await ERC20Full.deployed()

  	assert.isOk(await instanceTokenManagement.isManagedToken(erc721Instance.address))
  	assert.isOk(await instanceTokenManagement.isManagedToken(erc20Instance.address))
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
  it("get held token ids", async () => {
  	let instanceTokenManagement = await TokenManagement.deployed()
  	let heldIds = await instanceTokenManagement.getHeldTokenIds(accounts[0])
  	
  	assert.isAbove(heldIds.length, 0, 'No held token ids returned.')

  	for(i=0; i < heldIds.length; i++){
  		switch(i){
  			case 0:	assert.equal(primary_tokenId1155.toString(), heldIds[i].toString(), 'primary_tokenId1155 does not match'); break;
	  		case 1:	assert.equal(ids[i-1], heldIds[i], 'batchmint id1 does not match'); break;
	  		case 2:	assert.equal(ids[i-1], heldIds[i], 'batchmint id2 does not match'); break;
	  		case 3:	assert.equal(ids[i-1], heldIds[i], 'batchmint id3 does not match'); break;
	  		case 4:	assert.equal(ids[i-1], heldIds[i], 'batchmint id4 does not match'); break;
	  		case 5:	assert.equal(ids[i-1], heldIds[i], 'batchmint id5 does not match'); break;
	  		case 6:	assert.equal(1, heldIds[i], 'erc721  id does not match'); break;
	  		case 7:	assert.equal(2, heldIds[i], 'minted fungible does not match'); break;
	  		case 8:	assert.equal(3, heldIds[i], 'idB does not match'); break;
  		}
  	}
  })
  it("get held token balances", async () => {
  	let instanceTokenManagement = await TokenManagement.deployed()
  	let balances = await instanceTokenManagement.getHeldTokenBalances(accounts[0])
  	assert.isAbove(balances.length, 0, 'No held token ids returned.')

  	for(i=0; i < balances.length; i++){
  		switch(i){
  			case 0:	assert.equal(
	  				ethers.utils.parseUnits('1000000000',18).toString(), 
	  				balances[i].toString(), 
	  				'tokenId11555 does not match'
  				)
  			break;
	  		case 1:	assert.equal(amounts[i-1], balances[i], 'batchmint balance1 does not match'); break;
	  		case 2:	assert.equal(amounts[i-1], balances[i], 'batchmint balance2 does not match'); break;
	  		case 3:	assert.equal(amounts[i-1], balances[i], 'batchmint balance3 does not match'); break;
	  		case 4:	assert.equal(amounts[i-1], balances[i], 'batchmint balance4 does not match'); break;
	  		case 5:	assert.equal(amounts[i-1], balances[i], 'batchmint balance5 does not match'); break;
	  		case 6:	assert.equal(0, balances[i], 'erc721  balance does not match'); break;
	  		case 7:	assert.equal(
		  			ethers.utils.parseUnits('900000000',18).toString(), 
		  			balances[i], 
		  			'minted fungible balance does not match'
	  			) 
	  		break;
	  		case 8:	assert.equal(0, balances[i], 'balanceB does not match'); break;
  		}
  	}
  })
})  
