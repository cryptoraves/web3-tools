import { Spec } from '@specron/spec';

const spec = new Spec();

spec.test('returns boolean', async (ctx) => {
  const main = await ctx.deploy({
    src: './build/cryptoravestoken.json',
    contract: 'CryptoravesToken',
  });
  const value = await main.instance.methods.works().call();
  ctx.is(value, '100');
});


export default spec;