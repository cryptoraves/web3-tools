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
	ctx.set('bob', accounts[1]);
	ctx.set('jane', accounts[2]);
	ctx.set('sara', accounts[3]);
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
spec.test('check manager address', async (ctx) => {

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

 	const owner = ctx.get('owner');

 	//await nftoken.instance.methods.mint(bob, id1).send({ from: owner });
	//const value = await cryptoravesContract.instance.methods.mint(owner, '1', '1000000000', 0).send({ from: owner });
	//const value = await cryptoravesContract.instance.methods.isManagedToken(ctx.get('bob')).call();

	const tokenManager = await validatorContract.instance.methods.getTokenManager().call();
	
	console.log(tokenManager)
	ctx.is(ctx.web3.utils.isAddress(tokenManager), true)

});
/*
spec.test('is bob\'s token managed', async (ctx) => {

 	const cryptoravesContract = ctx.get('cryptoravesContract');

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

 	const owner = ctx.get('owner');

 	//await nftoken.instance.methods.mint(bob, id1).send({ from: owner });
	const value = await cryptoravesContract.instance.methods.mint(owner, '1', '1000000000', 0).send({ from: owner });
	//const value = await cryptoravesContract.instance.methods.isManagedToken(ctx.get('bob')).call();
	console.log(value);
	ctx.is(value, false);
});

*/