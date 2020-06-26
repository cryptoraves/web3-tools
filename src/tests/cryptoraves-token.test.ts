import { Spec } from '@specron/spec';


/**
 * Spec context interfaces.
 */

interface Data {
	validatorContract?: any;
	cryptoravesContract?: any;
	owner?: string;
	bob?: string;
	jane?: string;
	sara?: string;
	zeroAddress?: string;
	id1?: string;
	id2?: string;
	id3?: string;
	uri1?: string;
}

/**
 * Spec stack instances.
 */

const spec = new Spec<Data>();

export default spec;

spec.beforeEach(async (ctx) => {
	const accounts = await ctx.web3.eth.getAccounts();
	ctx.set('owner', accounts[0]);
	
	ctx.set('zeroAddress', '0x0000000000000000000000000000000000000000');

	ctx.set('id1', '123');
	ctx.set('id2', '124');
	ctx.set('id3', '125');

	ctx.set('uri1', 'https://i.picsum.photos/id/0/200/200.jpg');
	
});

spec.beforeEach(async (ctx) => {
	
	const zeroAddress = ctx.get('zeroAddress');
	const uri1 = ctx.get('uri1');

	const validatorContract = await ctx.deploy({ 
		src: './build/CryptoravesAdministration/ValidatorInterfaceContract.json',
		contract: 'ValidatorSystem',
		args: [ uri1, zeroAddress ],
	});
	ctx.set('validatorContract', validatorContract);
	/* const cryptoravesContract = await ctx.deploy({ 
		src: './build/CryptoravesAdministration/CryptoravesToken.json',
		contract: 'CryptoravesToken',
		args: [''],
	}); 
	ctx.set('cryptoravesContract', cryptoravesContract);
	*/
  	

});
spec.test('Launch validator contract & get manager contract address', async (ctx) => {
	
	const validatorContract = ctx.get('validatorContract');

	const tokenManager = await validatorContract.instance.methods.getTokenManager().call();

	//also check isValidator() function 
	const isValidator = await validatorContract.instance.methods.isValidator().call();

	ctx.is(ctx.web3.utils.isAddress(tokenManager) && isValidator, true)

});

spec.test('Drop a crypto for Bob & check his balance', async (ctx) => {

 	const validatorContract = ctx.get('validatorContract');

 	let twitterIds = [
 		ctx.get('id1'),
 		ctx.get('id2'),
 		ctx.get('id3')
 	];

 	let twitterUserNames = [
 		'@bob',
 		'@jane',
 		'@sara'
 	]

 	const uri = ctx.get('uri1')
 	const isLaunch = true;

 	const validator = ctx.get('owner');
 console.log(validator)
 	//drop crypto here
 	await validatorContract.instance.methods.validateCommand(
 		twitterIds, twitterUserNames, '', true, 0, 0
 	).send({ from: validator });
console.log('here')	
 	//now check balance
 	let cryptoravesContract = ctx.get('cryptoravesContract')

 	const cryptoravesTokenId = cryptoravesContract.instance.methods.getTokenIdFromPlatformId(twitterIds[0])
 	console.log(cryptoravesTokenId)

 	const accountAddress = cryptoravesContract.instance.methods.getUserAccount(twitterIds[0])
 	console.log(accountAddress)

 	const balance = cryptoravesContract.instance.methods.balanceOf(accountAddress[0])
 	console.log(balance)
	ctx.is(balance, 1000000000);
});
