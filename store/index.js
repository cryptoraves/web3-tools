export const state = () => ({
  web3js: null,
  ethersProvider: null,
  ethereumAddress: null
})
export const mutations = {
  setEthersProvider(state, value) {
    console.log('setEthersProvider', value)
    state.ethersProvider = value
  },
  SET_VAR_2(state, value) {
    console.log('SET_VAR_2', value)
    state.var2 = value
  }
}
